<script lang="ts">
	import { supabase } from '$lib/supabaseClient';
	import { user } from '$lib/stores';
	import { get } from 'svelte/store';
	import { goto } from '$app/navigation';

	let allowlist = $state<string[]>([]);
	let newEmail = $state<string>('');
	let error = $state<string>('');
	let success = $state<string>('');
	let userRole = $state<string>('');
	let isLoading = $state<boolean>(true);

	async function checkAdminStatus() {
		const u = get(user);
		if (!u) {
			goto('/login');
			return;
		}

		try {
			const { data: profileData, error: profileError } = await supabase
				.from('profiles')
				.select('role')
				.eq('id', u.id)
				.single();

			if (profileError) {
				console.error('Profile check error:', profileError);
				userRole = 'user';
			} else {
				userRole = profileData?.role || 'user';
			}

			if (userRole !== 'admin') {
				goto('/');
				return;
			}
		} catch (error) {
			console.error('Error checking admin status:', error);
			userRole = 'user';
			goto('/');
		} finally {
			isLoading = false;
		}
	}

	async function loadAllowlist() {
		const { data, error: err } = await supabase
			.from('allowlist')
			.select('email, created_at')
			.order('created_at', { ascending: false });
		
		if (err) {
			error = err.message;
			return;
		}
		
		allowlist = data?.map(item => item.email) ?? [];
	}

	async function addToAllowlist() {
		if (!newEmail.trim()) return;
		
		const u = get(user);
		if (!u) return;

		const { error: err } = await supabase
			.from('allowlist')
			.insert({ email: newEmail.trim().toLowerCase(), created_by: u.id });

		if (err) {
			error = err.message;
			success = '';
		} else {
			success = `${newEmail} added to allowlist`;
			error = '';
			newEmail = '';
			loadAllowlist();
		}
	}

	async function removeFromAllowlist(email: string) {
		const { error: err } = await supabase
			.from('allowlist')
			.delete()
			.eq('email', email);

		if (err) {
			error = err.message;
			success = '';
		} else {
			success = `${email} removed from allowlist`;
			error = '';
			loadAllowlist();
		}
	}

	function handleSubmit(event: Event) {
		event.preventDefault();
		addToAllowlist();
	}

	$effect(() => {
		if ($user) {
			checkAdminStatus();
		} else {
			goto('/login');
		}
	});

	$effect(() => {
		if (userRole === 'admin' && !isLoading) {
			loadAllowlist();
		}
	});
</script>

<svelte:head>
	<title>Admin Panel - Don't Quote Me On That</title>
</svelte:head>

{#if isLoading}
	<div class="loading">
		<p>Checking admin permissions...</p>
	</div>
{:else if userRole === 'admin'}
	<div class="admin-container">
		<header class="admin-header">
			<h1>Admin Panel</h1>
			<nav>
				<a href="/" class="nav-link">← Back to Quotes</a>
				<button onclick={() => supabase.auth.signOut()}>Logout</button>
			</nav>
		</header>

		<main class="admin-content">
			<section class="allowlist-section">
				<h2>Manage Allowlist</h2>
				<p>Add or remove emails from the allowlist. Only allowlisted users can view and add quotes.</p>
				
				<form onsubmit={handleSubmit} class="add-form">
					<input 
						bind:value={newEmail} 
						placeholder="Email to add to allowlist" 
						type="email"
						required 
					/>
					<button type="submit">Add to Allowlist</button>
				</form>

				{#if error}
					<div class="message error">{error}</div>
				{/if}
				
				{#if success}
					<div class="message success">{success}</div>
				{/if}

				<div class="allowlist">
					<h3>Current Allowlist ({allowlist.length} emails)</h3>
					{#if allowlist.length === 0}
						<p class="empty-state">No emails in allowlist yet.</p>
					{:else}
						<div class="allowlist-items">
							{#each allowlist as email}
								<div class="allowlist-item">
									<span class="email">{email}</span>
									<button 
										onclick={() => removeFromAllowlist(email)}
										class="remove-btn"
									>
										Remove
									</button>
								</div>
							{/each}
						</div>
					{/if}
				</div>
			</section>

			<section class="admin-info">
				<h2>Admin Information</h2>
				<div class="info-card">
					<p><strong>Logged in as:</strong> {$user.email}</p>
					<p><strong>Role:</strong> {userRole}</p>
					<p><strong>Total allowlisted users:</strong> {allowlist.length}</p>
				</div>
			</section>
		</main>
	</div>
{:else}
	<div class="access-denied">
		<h2>Access Denied</h2>
		<p>You don't have admin privileges.</p>
		<a href="/">Go back to quotes</a>
	</div>
{/if}

<style>
	.admin-container {
		max-width: 800px;
		margin: 0 auto;
		padding: 2rem;
	}

	.admin-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 2rem;
		padding-bottom: 1rem;
		border-bottom: 2px solid #3c2f2f;
	}

	.admin-header h1 {
		color: #3c2f2f;
		margin: 0;
		font-size: 2rem;
	}

	.admin-header nav {
		display: flex;
		gap: 1rem;
		align-items: center;
	}

	.nav-link {
		color: #3c2f2f;
		text-decoration: none;
		padding: 0.5rem 1rem;
		border: 1px solid #3c2f2f;
		border-radius: 4px;
		transition: all 0.2s;
	}

	.nav-link:hover {
		background-color: #3c2f2f;
		color: white;
	}

	.admin-content {
		display: grid;
		gap: 2rem;
	}

	.allowlist-section {
		background-color: #f9f9f9;
		padding: 1.5rem;
		border-radius: 8px;
		border: 1px solid #ddd;
	}

	.add-form {
		display: flex;
		gap: 0.5rem;
		margin: 1rem 0;
	}

	.add-form input {
		flex: 1;
		padding: 0.75rem;
		border: 1px solid #ccc;
		border-radius: 4px;
		font-size: 1rem;
	}

	.add-form button {
		padding: 0.75rem 1.5rem;
		background-color: #3c2f2f;
		color: white;
		border: none;
		border-radius: 4px;
		cursor: pointer;
		font-size: 1rem;
		transition: background-color 0.2s;
	}

	.add-form button:hover {
		background-color: #5a4a4a;
	}

	.message {
		padding: 0.75rem;
		border-radius: 4px;
		margin: 1rem 0;
		font-weight: 500;
	}

	.message.error {
		background-color: #ffebee;
		color: #d32f2f;
		border: 1px solid #f44336;
	}

	.message.success {
		background-color: #e8f5e8;
		color: #2e7d32;
		border: 1px solid #4caf50;
	}

	.allowlist h3 {
		margin-top: 1.5rem;
		margin-bottom: 1rem;
		color: #3c2f2f;
	}

	.empty-state {
		text-align: center;
		color: #666;
		font-style: italic;
		padding: 2rem;
		background-color: white;
		border-radius: 4px;
		border: 1px dashed #ccc;
	}

	.allowlist-items {
		display: flex;
		flex-direction: column;
		gap: 0.5rem;
	}

	.allowlist-item {
		display: flex;
		justify-content: space-between;
		align-items: center;
		padding: 0.75rem;
		background-color: white;
		border: 1px solid #ddd;
		border-radius: 4px;
		transition: box-shadow 0.2s;
	}

	.allowlist-item:hover {
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
	}

	.email {
		font-family: monospace;
		font-weight: 500;
	}

	.remove-btn {
		background-color: #d32f2f;
		color: white;
		border: none;
		padding: 0.5rem 1rem;
		border-radius: 4px;
		cursor: pointer;
		font-size: 0.9rem;
		transition: background-color 0.2s;
	}

	.remove-btn:hover {
		background-color: #b71c1c;
	}

	.admin-info {
		background-color: #f0f8ff;
		padding: 1.5rem;
		border-radius: 8px;
		border: 1px solid #b3d9ff;
	}

	.info-card {
		background-color: white;
		padding: 1rem;
		border-radius: 4px;
		border: 1px solid #ddd;
	}

	.info-card p {
		margin: 0.5rem 0;
		color: #333;
	}

	.access-denied {
		text-align: center;
		padding: 4rem 2rem;
		background-color: #ffebee;
		border: 1px solid #f44336;
		border-radius: 8px;
		margin: 2rem;
	}

	.access-denied h2 {
		color: #d32f2f;
		margin-bottom: 1rem;
	}

	.access-denied a {
		color: #3c2f2f;
		text-decoration: none;
		font-weight: 500;
	}

	.loading {
		text-align: center;
		padding: 4rem 2rem;
		color: #666;
		font-size: 1.1rem;
	}

	button {
		background-color: #3c2f2f;
		color: white;
		border: none;
		padding: 0.5rem 1rem;
		border-radius: 4px;
		cursor: pointer;
		transition: background-color 0.2s;
	}

	button:hover {
		background-color: #5a4a4a;
	}
</style>
