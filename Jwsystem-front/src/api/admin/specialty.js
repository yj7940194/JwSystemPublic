import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/specialty/addSpecialty',
    method: 'post',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return Promise.all(
    ids.map(itemId => request({
      url: 'api/specialty/delete',
      method: 'delete',
      params: { id: itemId }
    }))
  )
}

export function edit(data) {
  return request({
    url: 'api/specialty/updateSpecialty',
    method: 'post',
    data
  })
}

export function getAll() {
  return request({
    url: 'api/specialty/listajax',
    method: 'get'
  })
}

export default { add, edit, del, getAll }
