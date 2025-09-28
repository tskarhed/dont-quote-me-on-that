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

<section id="login-form">
	<h2>Logga in</h2>
	<form onsubmit={login}>
		<input bind:value={email} placeholder="Email" required />
		<input type="password" bind:value={password} placeholder="Lösenord" required />
		<button type="submit">Logga in</button>
		<button type="button" onclick={signup}>Registrera</button>
	</form>
	{#if error}
		<p class="error-details">{error}</p>
	{/if}
</section>

<style>
	#login-form {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	#login-form form {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 0.5rem;
	}

	form input {
		grid-column: span 2;
	}

	button {
		width: 100%;
	}

	.error-details {
		color: #d32f2f !important;
		font-style: italic;
		font-size: 0.9rem;
		text-align: center;
		margin: 0.5rem 0;
	}
</style>
