<script lang="ts">
	import { goto } from "$app/navigation";
	import { onMount } from "svelte";
	import { db, chats } from "$lib/stores";

	// Redirect root path based on chat history
	onMount(async () => {
		// Load chats from database
		const allChats = await $db.getChats();
		
		if (allChats && allChats.length > 0) {
			// If there are chat histories, redirect to the last one
			const lastChat = allChats[0]; // Chats are ordered with latest first
			goto(`/c/${lastChat.id}`);
		} else {
			// If no chat histories, redirect to new chat
			goto("/new");
		}
	});
</script>


<div class="min-h-screen w-full flex justify-center items-center">
	<p>Redirecting...</p>
</div>