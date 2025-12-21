import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/college/saveOrUpdateCollege',
    method: 'post',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return request({
    url: 'api/college/deleteCollege',
    method: 'delete',
    params: { id: ids.join(',') }
  })
}

export function edit(data) {
  return request({
    url: 'api/college/editCollege',
    method: 'post',
    data
  })
}

export function getAll() {
  return request({
    url: 'api/college/listajax',
    method: 'get'
  })
}

export default { add, edit, del, getAll }
