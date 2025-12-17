import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/classes/add',
    method: 'post',
    data
  })
}

export function del(ids) {
  return request({
    url: 'api/classes/delete',
    method: 'get',
    params: { ids }
  })
}

export function edit(data) {
  // Backend lacks edit endpoint, maybe 'add' handles it?
  // But safest is to return error or empty.
  // We can just not export it or make it fail.
  // Or maybe use add?
  return Promise.reject('Update not supported by backend')
}

export default { add, del, edit }
