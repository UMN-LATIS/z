<template>
  <template v-if="isLoggedIn">
    <NavbarItem>
      <a href="/shortener/urls">My Z-Links</a>
    </NavbarItem>
    <NavbarItem>
      <a href="/shortener/groups">My Collections</a>
    </NavbarItem>
    <NavbarItem>
      <a href="/shortener/api_keys">API</a>
    </NavbarItem>
    <NavbarDropdown v-if="isAdmin" label="Admin">
      <NavbarItem>
        <a href="/shortener/admin/urls">All Urls</a>
      </NavbarItem>
      <NavbarItem>
        <a href="/shortener/admin/groups"> All Collections </a>
      </NavbarItem>
      <NavbarItem>
        <a href="/shortener/admin/members"> Manage Admins </a>
      </NavbarItem>
      <NavbarItem>
        <a href="/shortener/admin/audits"> Audit Logs </a>
      </NavbarItem>
    </NavbarDropdown>
  </template>
  <NavbarDropdown label="Help">
    <NavbarItem>
      <a
        href="https://it.umn.edu/services-technologies/how-tos/z-links-create-manage-z-links"
        >How To Use Z</a
      >
    </NavbarItem>
    <NavbarItem>
      <a href="/shortener/faq">FAQ</a>
    </NavbarItem>
    <NavbarItem>
      <a href="mailto:help@umn.edu">Contact Us</a>
    </NavbarItem>
  </NavbarDropdown>
  <NavbarItem v-if="!isLoggedIn">
    <a href="/shortener/signin">Sign In</a>
  </NavbarItem>
  <NavbarItem v-if="isLoggedIn">
    <a href="/shortener/signout">Sign Out</a>
  </NavbarItem>
</template>
<script setup lang="ts">
import { NavbarItem, NavbarDropdown } from "@umn-latis/cla-vue-template";
import type { User } from "@/types";
import { computed } from "vue";

const props = defineProps<{
  currentUser: User | null;
}>();

const isLoggedIn = computed(() => props.currentUser !== null);
const isAdmin = computed(() => props.currentUser?.admin ?? false);
</script>
<style scoped></style>
