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
  return request({
    url: 'api/plan',
    method: 'delete',
    params: { id }
  })
}

export default { add, edit, del }
