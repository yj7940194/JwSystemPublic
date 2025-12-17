<template>
  <div class="app-container">
    <el-alert
      title="我的选课"
      type="info"
      description="显示已选修的课程列表"
      show-icon
      :closable="false"
      style="margin-bottom: 20px;"
    />
    
    <el-card>
      <div slot="header" class="clearfix">
        <span>已选课程</span>
        <el-button style="float: right; padding: 3px 0" type="text" @click="loadData">刷新</el-button>
      </div>
      
      <el-table
        :data="courseList"
        v-loading="loading"
        border
        style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center"/>
        <el-table-column prop="courseName" label="课程名称" min-width="150"/>
        <el-table-column prop="teacherName" label="任课教师" width="120" align="center"/>
        <el-table-column prop="credit" label="学分" width="80" align="center"/>
        <el-table-column prop="time" label="上课时间" width="200" show-overflow-tooltip>
          <template slot-scope="scope">
            {{ scope.row.wname }} {{ scope.row.sse }}
          </template>
        </el-table-column>
        <el-table-column prop="classroom" label="上课地点" width="150" align="center"/>
        <el-table-column prop="status" label="状态" width="100" align="center">
          <template slot-scope="scope">
            <el-tag type="success">已选</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" align="center">
          <template slot-scope="scope">
            <el-button type="danger" size="mini" disabled>退课</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "StudentCourse",
  data() {
    return {
      courseList: [],
      loading: false
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      request.get('/api/score/findSelectCourseByStudentId')
        .then(res => {
          this.courseList = res.data;
        })
        .catch(err => {
          console.error(err);
          this.$message.error('获取选课信息失败');
        })
        .finally(() => {
          this.loading = false;
        });
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
