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
            :label="formatCourseLabel(item)"
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
        <el-table-column label="缺勤" prop="absent" width="80" align="center"/>
        
        <el-table-column label="考勤(0-100)" width="160" align="center">
          <template slot-scope="scope">
            <el-input-number v-model="scope.row.attendanceRaw" :min="0" :max="100" size="small"></el-input-number>
          </template>
        </el-table-column>

        <el-table-column label="平时成绩" width="150" align="center">
           <template slot-scope="scope">
              <el-input-number v-model="scope.row.usuallyRaw" :min="0" :max="100" size="small"></el-input-number>
           </template>
        </el-table-column>
        
        <el-table-column label="期末成绩" width="150" align="center">
           <template slot-scope="scope">
              <el-input-number v-model="scope.row.examRaw" :min="0" :max="100" size="small"></el-input-number>
           </template>
        </el-table-column>
        
        <el-table-column label="总评" prop="score" width="100" align="center">
           <template slot-scope="scope">
             <span style="font-weight: bold">{{ calculateScore(scope.row) }}</span>
           </template>
        </el-table-column>
        
        <el-table-column label="操作" width="100" align="center">
          <template slot-scope="scope">
             <el-button type="text" :loading="scope.row.saving" @click="saveRow(scope.row)">保存</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div style="margin-top: 20px; text-align: center" v-if="studentList.length > 0">
         <el-button type="primary" :loading="bulkSaving" @click="submitAll">批量提交成绩</el-button>
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
      bulkSaving: false,
      query: {
        id: '', // courseId
        offset: 1,
        limit: 100
      }
    };
  },
  mounted() {
    this.loadCourses();
  },
  methods: {
    formatCourseLabel(item) {
      const name = item && (item.name || item.courseName || item.cname) ? (item.name || item.courseName || item.cname) : '课程'
      const timeParts = [item && item.sw, item && item.sse].filter(Boolean).join(' ')
      const room = item && item.classroom ? item.classroom : ''
      const suffix = [timeParts, room].filter(Boolean).join(' ')
      return suffix ? `${name}（${suffix}）` : name
    },
    loadCourses() {
      // Reuse findCourseByteacherId to populate select
      request.get('/api/course/findCourseByteacherId', { params: { offset: 1, limit: 200 } })
        .then(res => {
          const rows = (res && (res.rows || res.content)) || []
          this.courseOptions = Array.isArray(rows) ? rows : []
          // Auto-select first course for demo UX
          if (!this.query.id && this.courseOptions.length) {
            this.tryPickCourseWithStudents()
          }
        });
    },
    tryPickCourseWithStudents() {
      const maxTry = Math.min(this.courseOptions.length, 5)
      const run = async () => {
        for (let i = 0; i < maxTry; i++) {
          this.query.id = this.courseOptions[i].id
          // eslint-disable-next-line no-await-in-loop
          const ok = await this.loadStudents()
          if (ok) return
        }
      }
      run()
    },
    loadStudents() {
      if (!this.query.id) return;
      
      this.loading = true;
      return request.get('/api/course/findStudentByCourseId', { params: { id: this.query.id, offset: 1, limit: 200 } })
        .then(res => {
          const rows = (res && (res.rows || res.content)) || []
          const list = Array.isArray(rows) ? rows : []
          this.studentList = list.map(item => ({
            ...item,
            studentId: item.sid || item.studentId,
            studentName: item.sname || item.studentName,
            classesName: item.cname || item.classname || item.classesName,
            absent: Number(item.absent) || 0,
            // 后端存的是“加权后”的分数：attendance(0-20), usually(0-20), exam(0-60)
            attendanceRaw: item.attendance === null || item.attendance === undefined ? 0 : Math.round(Number(item.attendance) * 5),
            usuallyRaw: item.usually === null || item.usually === undefined ? 0 : Math.round(Number(item.usually) * 5),
            examRaw: item.exam === null || item.exam === undefined ? 0 : Math.round(Number(item.exam) / 0.6),
            saving: false
          }))
          return this.studentList.length > 0
        })
        .catch(() => {
          this.studentList = []
          return false
        })
        .finally(() => {
          this.loading = false;
        });
    },
    calculateScore(row) {
      const a = Number(row.attendanceRaw) || 0
      const u = Number(row.usuallyRaw) || 0
      const e = Number(row.examRaw) || 0
      return Math.round(a * 0.2 + u * 0.2 + e * 0.6)
    },
    async saveRow(row) {
      if (!this.query.id || !row || !row.studentId) return
      row.saving = true
      try {
        await request.post('/api/score/addScore', {
          cid: this.query.id,
          sid: row.studentId,
          attendance: Number(row.attendanceRaw) || 0,
          usually: Number(row.usuallyRaw) || 0,
          exam: Number(row.examRaw) || 0
        })
        this.$message.success('保存成功')
      } catch (e) {
        this.$message.error('保存失败')
      } finally {
        row.saving = false
      }
    },
    async submitAll() {
      if (!this.query.id || this.studentList.length === 0) return
      this.bulkSaving = true
      const failed = []
      for (const row of this.studentList) {
        // eslint-disable-next-line no-await-in-loop
        try {
          await request.post('/api/score/addScore', {
            cid: this.query.id,
            sid: row.studentId,
            attendance: Number(row.attendanceRaw) || 0,
            usually: Number(row.usuallyRaw) || 0,
            exam: Number(row.examRaw) || 0
          })
        } catch (e) {
          failed.push(row.studentId)
        }
      }
      this.bulkSaving = false
      if (failed.length) {
        this.$message.warning(`部分保存失败：${failed.slice(0, 5).join(', ')}${failed.length > 5 ? '...' : ''}`)
      } else {
        this.$message.success('批量保存成功')
      }
      // Refresh to reflect backend computed score/point/status
      await this.loadStudents()
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
