<script lang="ts">
	import { goto } from '$app/navigation';
	import { supabase } from '$lib/supabaseClient';
	let email = '';
	let password = '';
	let error = '';

	// Check if user is already logged in and display text that they are logged in
	supabase.auth.getUser().then(({ data }) => {
		if (data.user) {
			goto('/');
		} else {
			error = 'You are not logged in';
		}
	});

	async function login() {
		const { error: err } = await supabase.auth.signInWithPassword({ email, password });
		if (err) error = err.message;

		// Reroute to home page
		goto('/');
	}

	async function signup() {
		const { error: err } = await supabase.auth.signUp({ email, password });
		if (err) error = err.message;
	}
</script>

<h2>Logga in</h2>
<form onsubmit={login} id="login-form">
	<input bind:value={email} placeholder="Email" />
	<input type="password" bind:value={password} placeholder="Lösenord" />
	<button type="submit">Logga in</button>
</form>
<p>{error}</p>
