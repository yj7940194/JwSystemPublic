import request from '@/utils/request'

export function findApply(params) {
  return request({
    url: 'api/teacherCourse/findApply',
    method: 'get',
    params
  })
}

export function add(data) {
  return request({
    url: 'api/teacherCourse',
    method: 'post',
    data
  })
}

export function edit(data) {
  return request({
    url: 'api/teacherCourse',
    method: 'put',
    data
  })
}

export function del(id) {
  const ids = Array.isArray(id) ? id : [id]
  return Promise.all(
    ids.map(itemId => request({
      url: 'api/teacherCourse',
      method: 'delete',
      params: { id: itemId }
    }))
  )
}

export function agree(id) {
  return request({
    url: 'api/teacherCourse/agree',
    method: 'put',
    params: { id }
  })
}

export function back(id) {
  return request({
    url: 'api/teacherCourse/back',
    method: 'put',
    params: { id }
  })
}

export default { add, edit, del, findApply, agree, back }
