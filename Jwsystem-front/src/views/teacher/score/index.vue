<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>成绩录入</span>
      </div>
      
      <div class="filter-container" style="margin-bottom: 20px;">
        <span class="filter-label">选择课程：</span>
        <el-select v-model="query.id" placeholder="请选择课程" @change="loadStudents" style="width: 300px">
          <el-option
            v-for="item in courseOptions"
            :key="item.id"
            :label="item.courseName + ' (' + item.classesName + ')'"
            :value="item.id">
          </el-option>
        </el-select>
        <span class="filter-tip" v-if="!query.id"><i class="el-icon-info"></i> 请先选择一门课程进行操作</span>
      </div>

      <el-table
        :data="studentList"
        v-loading="loading"
        border
        style="width: 100%"
        empty-text="请选择课程查询学生列表">
        <el-table-column label="学号" prop="studentId" width="150" align="center"/>
        <el-table-column label="姓名" prop="studentName" width="120" align="center"/>
        <el-table-column label="班级" prop="classesName" min-width="150" align="center"/>
        
        <el-table-column label="平时成绩" width="150" align="center">
           <template slot-scope="scope">
              <el-input-number v-model="scope.row.pingshi" :min="0" :max="100" size="small" :disabled="true"></el-input-number>
           </template>
        </el-table-column>
        
        <el-table-column label="期末成绩" width="150" align="center">
           <template slot-scope="scope">
              <el-input-number v-model="scope.row.qimo" :min="0" :max="100" size="small" :disabled="true"></el-input-number>
           </template>
        </el-table-column>
        
        <el-table-column label="总评" prop="score" width="100" align="center">
           <template slot-scope="scope">
             <span style="font-weight: bold">{{ calculateScore(scope.row) }}</span>
           </template>
        </el-table-column>
        
        <el-table-column label="操作" width="100" align="center">
          <template slot-scope="scope">
             <el-button type="text" disabled>保存</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div style="margin-top: 20px; text-align: center" v-if="studentList.length > 0">
         <el-button type="primary" disabled>批量提交成绩 (演示版只读)</el-button>
      </div>

    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "TeacherScore",
  data() {
    return {
      courseOptions: [],
      studentList: [],
      loading: false,
      query: {
        id: '', // courseId
        page: 1,
        size: 100 // Load all students
      }
    };
  },
  mounted() {
    this.loadCourses();
    // Check if courseId passed from route
    if (this.$route.query.courseId) {
      this.query.id = this.$route.query.courseId;
      this.loadStudents();
    }
  },
  methods: {
    loadCourses() {
      // Reuse findCourseByteacherId to populate select
      request.get('/api/course/findCourseByteacherId', { params: { page: 1, size: 100 } })
        .then(res => {
          if (res.data && res.data.rows) {
            this.courseOptions = res.data.rows;
          }
        });
    },
    loadStudents() {
      if (!this.query.id) return;
      
      this.loading = true;
      request.get('/api/course/findStudentByCourseId', { params: this.query })
        .then(res => {
          const data = res.data;
          if (data && data.rows) {
            // Add pseudo fields for editing simulation
            this.studentList = data.rows.map(item => ({
              ...item,
              pingshi: item.usualScore || 0,
              qimo: item.endScore || 0
            }));
          } else {
            this.studentList = [];
          }
        })
        .finally(() => {
          this.loading = false;
        });
    },
    calculateScore(row) {
      // Mock calculation: 30% usual + 70% end
      // Assuming score field exists or calculate it
      if (row.score) return row.score;
      return Math.round((row.pingshi * 0.3) + (row.qimo * 0.7));
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.filter-label {
  font-weight: bold;
  margin-right: 10px;
}
.filter-tip {
  margin-left: 15px;
  color: #909399;
  font-size: 13px;
}
</style>
