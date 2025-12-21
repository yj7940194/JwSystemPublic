import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/plan',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: 'api/plan',
    method: 'put',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return Promise.all(
    ids.map(itemId => request({
      url: 'api/plan',
      method: 'delete',
      params: { id: itemId }
    }))
  )
}

export default { add, edit, del }
