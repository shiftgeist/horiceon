export async function isOnline() {
  let isOnline

  try {
    await fetch('https://fast.com')
    isOnline = true
  } catch (error) {
    isOnline = false
  }

  return isOnline
}
