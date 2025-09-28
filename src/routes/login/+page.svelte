<script lang="ts">
	import { goto } from '$app/navigation';
	import { supabase } from '$lib/supabaseClient';
	let email = '';
	let password = '';
	let error = '';

	// Check if user is already logged in and redirect to home
	supabase.auth.getUser().then(({ data }) => {
		if (data.user) {
			goto('/');
		}
	});

	async function login() {
		error = '';

		const { error: err } = await supabase.auth.signInWithPassword({ email, password });
		if (err) {
			error = err.message;
		} else {
			// Reroute to home page on successful login
			goto('/');
		}
	}
</script>

<section id="login-form">
	<h2>Logga in</h2>
	<form onsubmit={login}>
		<input bind:value={email} placeholder="Email" required />
		<input type="password" bind:value={password} placeholder="Lösenord" required />
		<button type="submit">Logga in</button>
	</form>
	{#if error}
		<p class="error-details">{error}</p>
	{/if}
	<p class="signup-link">
		Har du inget konto? <a href="/signup">Registrera dig här</a>
	</p>
</section>

<style>
	#login-form {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	#login-form form {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	form input {
		padding: 0.5rem;
		border: 1px solid #ccc;
		border-radius: 4px;
	}

	.error-details {
		color: #d32f2f !important;
		font-style: italic;
		font-size: 1rem;
		text-align: center;
		margin: 0.5rem 0;
	}

	.signup-link {
		text-align: center;
		margin-top: 1rem;
		font-size: 1rem;
	}

	.signup-link a {
		color: #007bff;
		text-decoration: none;
	}

	.signup-link a:hover {
		text-decoration: underline;
	}
</style>
