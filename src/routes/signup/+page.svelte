<script lang="ts">
	import { goto } from '$app/navigation';
	import { supabase } from '$lib/supabaseClient';
	let email = '';
	let password = '';
	let confirmPassword = '';
	let error = '';
	let success = '';

	// Check if user is already logged in and redirect to home
	supabase.auth.getUser().then(({ data }) => {
		if (data.user) {
			goto('/');
		}
	});

	async function signup() {
		error = '';
		success = '';

		// Validate passwords match
		if (password !== confirmPassword) {
			error = 'Lösenorden matchar inte';
			return;
		}

		// Validate password length
		if (password.length < 6) {
			error = 'Lösenordet måste vara minst 6 tecken';
			return;
		}

		const { error: err } = await supabase.auth.signUp({ email, password });
		if (err) {
			error = err.message;
		} else {
			success = 'Registrering lyckades! Kontrollera din e-post för att verifiera ditt konto.';
		}
	}
</script>

<section id="signup-form">
	<h2>Registrera dig</h2>
	<form onsubmit={signup}>
		<input bind:value={email} placeholder="Email" type="email" required />
		<input type="password" bind:value={password} placeholder="Lösenord" required />
		<input type="password" bind:value={confirmPassword} placeholder="Bekräfta lösenord" required />
		<button type="submit">Registrera</button>
	</form>
	{#if error}
		<p class="error-details">{error}</p>
	{/if}
	{#if success}
		<p class="success-details">{success}</p>
		<div class="success-actions">
			<a href="/" class="main-page-button">Gå till huvudsidan</a>
		</div>
	{/if}
	<p class="login-link">
		Har du redan ett konto? <a href="/login">Logga in här</a>
	</p>
</section>

<style>
	#signup-form {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	#signup-form form {
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
		font-size: 0.9rem;
		text-align: center;
		margin: 0.5rem 0;
	}

	.success-details {
		color: #2e7d32 !important;
		font-style: italic;
		font-size: 0.9rem;
		text-align: center;
		margin: 0.5rem 0;
	}

	.success-actions {
		text-align: center;
		margin: 1rem 0;
	}

	.main-page-button {
		display: inline-block;
		padding: 0.5rem 1rem;
		background-color: #007bff;
		color: white;
		text-decoration: none;
		border-radius: 4px;
		font-size: 0.9rem;
	}

	.main-page-button:hover {
		background-color: #0056b3;
	}

	.login-link {
		text-align: center;
		margin-top: 1rem;
		font-size: 0.9rem;
	}

	.login-link a {
		color: #007bff;
		text-decoration: none;
	}

	.login-link a:hover {
		text-decoration: underline;
	}
</style>
