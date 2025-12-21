import store from '@/store'

export default {
  inserted(el, binding, vnode) {
    const { value } = binding
    const roles = store.getters && store.getters.roles
    if (!value) {
      return
    }
    if (value instanceof Array && value.length > 0) {
      const permissionRoles = value

      const hasPermission = roles.some(role => {
        return permissionRoles.includes(role)
      })

      if (!hasPermission) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    } else {
      // Ignore invalid usage to avoid crashing the whole render tree.
      // Correct usage: v-permission="['admin','editor']"
      // eslint-disable-next-line no-console
      console.warn(`v-permission expects an array, got:`, value)
    }
  }
}
