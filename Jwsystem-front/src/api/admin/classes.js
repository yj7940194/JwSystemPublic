import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/classes/add',
    method: 'post',
    data
  })
}

export function del(ids) {
  const idList = Array.isArray(ids) ? ids : [ids]
  return Promise.all(
    idList.map(id => request({
      url: 'api/classes/delete',
      method: 'delete',
      params: { id }
    }))
  )
}

export function edit(data) {
  return request({
    url: 'api/classes/update',
    method: 'post',
    data
  })
}

export default { add, del, edit }
