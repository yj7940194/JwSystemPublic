import request from '@/utils/request'

export function find(params) {
  return request({
    url: 'api/program/findProgram',
    method: 'get',
    params
  })
}

export function add(data) {
  return request({
    url: 'api/program',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: 'api/program',
    method: 'put',
    data
  })
}

export function del(id) {
  return request({
    url: 'api/program',
    method: 'delete',
    params: { id }
  })
}

export default { add, edit, del, find }
