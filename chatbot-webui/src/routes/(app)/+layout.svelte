<script lang="ts">
	import { v4 as uuidv4 } from "uuid";
	import { openDB, deleteDB } from "idb";
	import { onMount, tick } from "svelte";
	import { goto } from "$app/navigation";

	import { info, showSettings, settings, models, db, chats, chatId, currentTitle } from "$lib/stores";

	import SettingsModal from "$lib/components/chat/SettingsModal.svelte";
	import Sidebar from "$lib/components/layout/Sidebar.svelte";
	import Navbar from "$lib/components/layout/Navbar.svelte";
	import toast from "svelte-french-toast";

	let loaded = false;
let sidebarVisible = false;
let currentModels = [];

	const getModels = async () => {
		// 由于使用云上大模型，不再从Ollama获取模型列表
		// 从用户配置中获取模型列表
		return $settings?.modelsConfig?.map(model => ({
			name: model.model,
			digest: "",
			size: "",
			modified_at: ""
		})) || [];
	};

	const getDB = async () => {
		const DB = await openDB("Chats", 1, {
			upgrade(db) {
				const store = db.createObjectStore("chats", {
					keyPath: "id",
					autoIncrement: true
				});
				store.createIndex("timestamp", "timestamp");
			}
		});

		return {
			db: DB,
			getChatById: async function (id) {
				return await this.db.get("chats", id);
			},
			getChats: async function () {
				let chats = await this.db.getAllFromIndex("chats", "timestamp");
				chats = chats.map((item, idx) => ({
					title: chats[chats.length - 1 - idx].title,
					id: chats[chats.length - 1 - idx].id
				}));
				return chats;
			},
			exportChats: async function () {
				let chats = await this.db.getAllFromIndex("chats", "timestamp");
				chats = chats.map((item, idx) => chats[chats.length - 1 - idx]);
				return chats;
			},
			addChats: async function (_chats) {
				for (const chat of _chats) {
					console.log(chat);
					await this.addChat(chat);
				}
				await chats.set(await this.getChats());
			},
			addChat: async function (chat) {
				await this.db.put("chats", {
					...chat
				});
			},
			createNewChat: async function (chat) {
				await this.addChat({ ...chat, timestamp: Date.now() });
				await chats.set(await this.getChats());
			},
			updateChatById: async function (id, updated) {
				const chat = await this.getChatById(id);

				await this.db.put("chats", {
					...chat,
					...updated,
					timestamp: Date.now()
				});

				await chats.set(await this.getChats());
			},
			deleteChatById: async function (id) {
				if ($chatId === id) {
					goto("/");
					await chatId.set(uuidv4());
				}
				await this.db.delete("chats", id);
				await chats.set(await this.getChats());
			},
			deleteAllChat: async function () {
				const tx = this.db.transaction("chats", "readwrite");
				await Promise.all([tx.store.clear(), tx.done]);

				await chats.set(await this.getChats());
			}
		};
	};





	onMount(async () => {
		await settings.set(JSON.parse(localStorage.getItem("settings") ?? "{}"));

		// 获取模型列表（从用户配置中）
		await models.set(await getModels());


		let _db = await getDB();
		await db.set(_db);

		await tick();
		loaded = true;
	});
</script>

{#if loaded}
	<div class="app relative">

		<div
			class=" text-gray-700 dark:text-gray-100 bg-white dark:bg-gray-800 min-h-screen overflow-auto flex flex-row"
		>
			<Sidebar on:visibilityChange={(e) => {
				sidebarVisible = e.detail;
			}} />

			<SettingsModal bind:show={$showSettings} />

			<div class="flex-1 {sidebarVisible ? 'ml-[260px]' : 'ml-0'} transition-all duration-300">
				<Navbar title={$currentTitle} {currentModels} />
				<div class="pt-16">
					<slot />
				</div>
			</div>
		</div>
	</div>
{/if}

<style>
	.loading {
		display: inline-block;
		clip-path: inset(0 1ch 0 0);
		animation: l 1s steps(3) infinite;
		letter-spacing: -0.5px;
	}

	@keyframes l {
		to {
			clip-path: inset(0 -1ch 0 0);
		}
	}

	pre[class*="language-"] {
		position: relative;
		overflow: auto;

		/* make space  */
		margin: 5px 0;
		padding: 1.75rem 0 1.75rem 1rem;
		border-radius: 10px;
	}

	pre[class*="language-"] button {
		position: absolute;
		top: 5px;
		right: 5px;

		font-size: 0.9rem;
		padding: 0.15rem;
		background-color: #828282;

		border: ridge 1px #7b7b7c;
		border-radius: 5px;
		text-shadow: #c4c4c4 0 0 2px;
	}

	pre[class*="language-"] button:hover {
		cursor: pointer;
		background-color: #bcbabb;
	}
</style>
