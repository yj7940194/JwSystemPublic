import request from '@/utils/request'

export function findMenuByRole(roleId) {
  return request({
    url: 'api/role/findMenuByRole',
    method: 'get',
    params: { roleId }
  })
}

export function add(data) {
  return request({
    url: 'api/role/add',
    method: 'post',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return Promise.all(
    ids.map(roleId => request({
      url: 'api/role/delete',
      method: 'delete',
      params: { roleId }
    }))
  )
}

export function edit(data) {
  return request({
    url: 'api/role/edit',
    method: 'put',
    data
  })
}

export function saveMenu(data) {
  return request({
    url: 'api/role/saveMenu',
    method: 'post',
    data
  })
}

export default { add, edit, del, saveMenu, findMenuByRole }
