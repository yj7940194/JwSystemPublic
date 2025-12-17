import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/specialty/addSpecialty',
    method: 'post',
    data
  })
}

export function del(id) {
  return request({
    url: 'api/specialty/delete',
    method: 'delete',
    params: { id }
  })
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
