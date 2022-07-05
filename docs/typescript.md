# Typescript

## Convert file input to image src

```vue
<script setup lang="ts">
const file = ref();
</script>

<template>
  <input type="file" @change="(e) => (file = e.target.files[0])" />

  <img :src="URL.createObjectURL(file)" alt="Preview" />
</template>
```
