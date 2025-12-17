import request from '@/utils/request'

export function listajax() {
  return request({
    url: 'api/college/listajax',
    method: 'get'
  })
}

export function add(data) {
  return request({
    url: 'api/user/add',
    method: 'post',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return Promise.all(
    ids.map(userId => request({
      url: 'api/user/delete',
      method: 'delete',
      params: { id: userId }
    }))
  )
}

export function edit(data) {
  const payload = { ...data }
  if (!payload.password) {
    delete payload.password
  }
  return request({
    url: 'api/user/edit',
    method: 'put',
    data: payload
  })
}

export default { add, edit, del, listajax }
