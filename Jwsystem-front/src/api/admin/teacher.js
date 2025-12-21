import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/teacher',
    method: 'post',
    data
  })
}

export function del(tid) {
  const ids = Array.isArray(tid) ? tid : [tid]
  return Promise.all(
    ids.map(id => request({
      url: 'api/teacher',
      method: 'delete',
      params: { tid: id }
    }))
  )
}

export function edit(data) {
  return request({
    url: 'api/teacher',
    method: 'put',
    data
  })
}

export function listajax(params) {
  return request({
    url: 'api/teacher/listajax',
    method: 'get',
    params
  })
}

export default { add, edit, del, listajax }
