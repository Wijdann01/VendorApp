import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

const respond = (body: Record<string, unknown>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })

const validRole = (role: unknown): role is 'super_admin' | 'editor' =>
  role === 'super_admin' || role === 'editor'

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (request.method !== 'POST') return respond({ error: 'Metode tidak didukung.' }, 405)

  const authorization = request.headers.get('Authorization')
  if (!authorization) return respond({ error: 'Autentikasi diperlukan.' }, 401)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  if (!supabaseUrl || !anonKey || !serviceRoleKey) {
    return respond({ error: 'Konfigurasi Supabase Edge Function belum lengkap.' }, 500)
  }

  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { autoRefreshToken: false, persistSession: false },
  })
  const { data: { user }, error: userError } = await callerClient.auth.getUser()
  if (userError || !user) return respond({ error: 'Sesi admin tidak valid atau sudah berakhir.' }, 401)

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })
  const { data: callerProfile, error: callerProfileError } = await admin
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single()
  if (callerProfileError || callerProfile?.role !== 'super_admin') {
    return respond({ error: 'Hanya super admin yang dapat mengelola akun.' }, 403)
  }

  let body: Record<string, unknown>
  try {
    body = await request.json()
  } catch {
    return respond({ error: 'Format permintaan tidak valid.' }, 400)
  }

  try {
    if (body.action === 'list') {
      const { data: profiles, error } = await admin
        .from('profiles')
        .select('id,full_name,role,created_at')
        .order('created_at', { ascending: false })
        .limit(500)
      if (error) throw error

      const authUsers = []
      for (let page = 1; ; page += 1) {
        const { data, error: usersError } = await admin.auth.admin.listUsers({ page, perPage: 100 })
        if (usersError) throw usersError
        authUsers.push(...data.users)
        if (data.users.length < 100) break
      }
      const emails = new Map(authUsers.map((authUser) => [authUser.id, authUser.email || '']))
      return respond({
        users: (profiles || []).map((profile) => ({ ...profile, email: emails.get(profile.id) || '' })),
      })
    }

    if (body.action === 'create') {
      const fullName = typeof body.full_name === 'string' ? body.full_name.trim() : ''
      const email = typeof body.email === 'string' ? body.email.trim().toLowerCase() : ''
      const password = typeof body.password === 'string' ? body.password : ''
      const role = body.role
      if (fullName.length < 2 || fullName.length > 120) {
        return respond({ error: 'Nama harus berisi 2–120 karakter.' }, 400)
      }
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
        return respond({ error: 'Format email tidak valid.' }, 400)
      }
      if (password.length < 8) return respond({ error: 'Kata sandi harus minimal 8 karakter.' }, 400)
      if (!validRole(role)) return respond({ error: 'Role akun tidak valid.' }, 400)

      const { data, error } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name: fullName },
      })
      if (error) throw error

      const { error: profileError } = await admin
        .from('profiles')
        .update({ full_name: fullName, role })
        .eq('id', data.user.id)
      if (profileError) {
        const { error: rollbackError } = await admin.auth.admin.deleteUser(data.user.id)
        if (rollbackError) throw new Error(`${profileError.message} Akun Auth gagal dibersihkan: ${rollbackError.message}`)
        throw profileError
      }
      return respond({ id: data.user.id })
    }

    if (body.action === 'update') {
      const id = typeof body.id === 'string' ? body.id : ''
      if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(id)) {
        return respond({ error: 'ID akun tidak valid.' }, 400)
      }
      const updates: { email?: string; password?: string; user_metadata?: { full_name: string } } = {}
      const profileUpdates: { full_name?: string; role?: 'super_admin' | 'editor' } = {}
      if (typeof body.full_name === 'string') {
        const fullName = body.full_name.trim()
        if (fullName.length < 2 || fullName.length > 120) return respond({ error: 'Nama harus berisi 2–120 karakter.' }, 400)
        profileUpdates.full_name = fullName
        updates.user_metadata = { full_name: fullName }
      }
      if (typeof body.email === 'string') {
        const email = body.email.trim().toLowerCase()
        if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || email.length > 254) {
          return respond({ error: 'Format email tidak valid.' }, 400)
        }
        updates.email = email
      }
      if (typeof body.password === 'string' && body.password.length > 0) {
        if (body.password.length < 8) return respond({ error: 'Kata sandi harus minimal 8 karakter.' }, 400)
        updates.password = body.password
      }
      if (body.role !== undefined) {
        if (!validRole(body.role)) return respond({ error: 'Role akun tidak valid.' }, 400)
        profileUpdates.role = body.role
      }
      if (!Object.keys(updates).length && !Object.keys(profileUpdates).length) {
        return respond({ error: 'Tidak ada perubahan akun yang diberikan.' }, 400)
      }

      const { data: target, error: targetError } = await admin
        .from('profiles')
        .select('id,role')
        .eq('id', id)
        .single()
      if (targetError) throw targetError
      if (id === user.id && profileUpdates.role === 'editor') {
        return respond({ error: 'Anda tidak dapat menurunkan role akun yang sedang digunakan.' }, 400)
      }

      if (Object.keys(updates).length) {
        const { error } = await admin.auth.admin.updateUserById(id, updates)
        if (error) throw error
      }
      if (Object.keys(profileUpdates).length) {
        const { error } = await admin.from('profiles').update(profileUpdates).eq('id', id)
        if (error) throw error
      }
      return respond({ id: target.id })
    }

    if (body.action === 'delete') {
      const id = typeof body.id === 'string' ? body.id : ''
      if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(id)) {
        return respond({ error: 'ID akun tidak valid.' }, 400)
      }
      if (id === user.id) return respond({ error: 'Anda tidak dapat menghapus akun yang sedang digunakan.' }, 400)
      const { error } = await admin.auth.admin.deleteUser(id)
      if (error) throw error
      return respond({ id })
    }

    return respond({ error: 'Aksi pengelolaan akun tidak dikenal.' }, 400)
  } catch (error) {
    return respond({ error: error instanceof Error ? error.message : 'Pengelolaan akun gagal.' }, 400)
  }
})
