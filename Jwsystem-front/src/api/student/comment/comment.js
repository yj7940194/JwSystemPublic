import request from '@/utils/request'

// 评价批次（管理员发布）
export function listCommentBatches(params) {
  return request({
    url: 'api/comment/pageQuery',
    method: 'get',
    params
  })
}

// 学生待评/已评任务列表
export function listTeamComments(params) {
  return request({
    url: 'api/teamComment/pageQuery',
    method: 'get',
    params
  })
}

// 查询某个任务的评价详情（学生视角：会自动取当前登录学生）
// 注意：后端参数名为 cid(teacher_course.id) 与 tcId(team_comment.id)
export function queryCourseComment(params) {
  return request({
    url: 'api/courseComment/queryCourseComment',
    method: 'get',
    params
  })
}

// 提交学生评价（提交后会把 team_comment.status 置为 1，并计算 remark）
export function addCourseComment(data) {
  return request({
    url: 'api/courseComment',
    method: 'post',
    data
  })
}

export default { listCommentBatches, listTeamComments, queryCourseComment, addCourseComment }
