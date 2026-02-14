import { writable } from "svelte/store";
// Backend
export const info = writable({});

// Frontend
export const db = writable(undefined);
export const chatId = writable("");
export const chats = writable([]);
export const models = writable([]);

// Default settings with nanobot model
export const settings = writable({
	modelsConfig: [
		{
			id: "1",
			name: "nanobot",
			url: "http://127.0.0.1:5679/v1",
			apiKey: "",
			isDefault: true
		}
	]
});

export const showSettings = writable(false);
export const currentTitle = writable("");
