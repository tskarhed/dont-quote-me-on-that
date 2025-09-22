<script lang="ts">
    import { supabase } from '$lib/supabaseClient'
    let email = ''
    let password = ''
    let error = ''
  
    async function login() {
      const { error: err } = await supabase.auth.signInWithPassword({ email, password })
      if (err) error = err.message
    }
  
    async function signup() {
      const { error: err } = await supabase.auth.signUp({ email, password })
      if (err) error = err.message
    }
  </script>
  
  <h1>Login</h1>
  <input bind:value={email} placeholder="Email" />
  <input type="password" bind:value={password} placeholder="Password" />
  <button on:click={login}>Login</button>
  <button on:click={signup}>Sign up</button>
  <p>{error}</p>