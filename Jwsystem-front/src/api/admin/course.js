import request from '@/utils/request'

export function add(data) {
  return request({
    url: 'api/course/add',
    method: 'post',
    data
  })
}

export function listajax(params) {
  return request({
    url: 'api/course/listajax',
    method: 'get',
    params
  })
}

export function endApply(params) {
  return request({
    url: 'api/course/endApply',
    method: 'get',
    params
  })
}

export function updateCourseEnd(data) {
  return request({
    url: 'api/course/updateCourseEnd',
    method: 'put',
    data
  })
}

export function findStudentByCourseId(params) {
  return request({
    url: 'api/course/findStudentByCourseId',
    method: 'get',
    params
  })
}

export default { add, listajax, endApply, updateCourseEnd, findStudentByCourseId }