<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>申请新课程</span>
      </div>
      
      <el-form ref="form" :model="form" label-width="120px" style="max-width: 600px; margin-top: 20px;">
        <el-form-item label="课程名称">
          <el-input v-model="form.courseName" placeholder="请输入课程名称"></el-input>
        </el-form-item>
        
        <el-form-item label="课程性质">
          <el-select v-model="form.type" placeholder="请选择">
            <el-option label="必修" value="必修"></el-option>
            <el-option label="选修" value="选修"></el-option>
          </el-select>
        </el-form-item>
        
        <el-form-item label="学分">
          <el-input-number v-model="form.credit" :min="1" :max="10"></el-input-number>
        </el-form-item>
        
        <el-form-item label="预计人数">
           <el-input-number v-model="form.peoplecount" :min="10" :max="200"></el-input-number>
        </el-form-item>
        
        <el-form-item label="上课周次">
           <el-select v-model="form.wname" placeholder="选择星期">
              <el-option v-for="w in ['星期一','星期二','星期三','星期四','星期五']" :key="w" :label="w" :value="w"/>
           </el-select>
        </el-form-item>
        
        <el-form-item label="上课节次">
           <el-select v-model="form.sse" placeholder="选择节次">
              <el-option v-for="s in ['1-2节','3-4节','5-6节','7-8节']" :key="s" :label="s" :value="s"/>
           </el-select>
        </el-form-item>
        
        <el-form-item>
          <el-button type="primary" @click="onSubmit" :loading="loading">提交申请</el-button>
          <el-button @click="resetForm">重置</el-button>
        </el-form-item>
      </el-form>
      
      <el-divider content-position="left">
        申请记录
        <el-button style="float: right; padding: 3px 0" type="text" @click="loadApplyRecords">刷新</el-button>
      </el-divider>

      <el-table
        v-if="applyRecords.length"
        :data="applyRecords"
        v-loading="recordsLoading"
        size="small"
        border
        style="width: 100%"
      >
        <el-table-column label="课程" prop="name" min-width="160" />
        <el-table-column label="上课时间" min-width="180">
          <template slot-scope="scope">
            {{ scope.row.sw }} {{ scope.row.sse }} / {{ scope.row.wname }}
          </template>
        </el-table-column>
        <el-table-column label="教室" prop="classroom" width="120" align="center" />
        <el-table-column label="容量" prop="totalPeople" width="90" align="center" />
        <el-table-column label="状态" width="110" align="center">
          <template slot-scope="scope">
            <el-tag v-if="Number(scope.row.apply) === 1" type="success">已通过</el-tag>
            <el-tag v-else-if="Number(scope.row.apply) === 2" type="danger">已驳回</el-tag>
            <el-tag v-else type="warning">待审核</el-tag>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-else-if="!recordsLoading" description="暂无申请记录"></el-empty>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "TeacherCourseApply",
  data() {
    return {
      form: {
        courseName: '',
        type: '选修',
        credit: 2,
        peoplecount: 50,
        wname: '',
        sse: ''
      },
      loading: false,
      recordsLoading: false,
      applyRecords: []
    };
  },
  mounted() {
    this.loadApplyRecords()
  },
  methods: {
    loadApplyRecords() {
      this.recordsLoading = true
      request.get('/api/teacherCourse/findApplyByTeacher', { params: { offset: 1, limit: 50 } })
        .then(res => {
          const rows = (res && (res.rows || res.content)) || []
          this.applyRecords = Array.isArray(rows) ? rows : []
        })
        .catch(() => {
          this.applyRecords = []
        })
        .finally(() => {
          this.recordsLoading = false
        })
    },
    onSubmit() {
      if (!this.form.courseName || !this.form.wname) {
        this.$message.warning('请填写完整信息');
        return;
      }
      
      this.loading = true;
      // 模拟提交或真实提交
      request.post('/api/course/add', this.form)
        .then(res => {
          const payload = res && res.data ? res.data : res
          if (payload && payload.status == 1) {
             this.$message.success('课程申请已提交');
             this.resetForm();
             this.loadApplyRecords()
          } else {
             this.$message.error((payload && payload.msg) || '提交失败');
          }
        })
        .catch(err => {
          // 这里可能会400 BadRequest如果后端校验不通过
          this.$message.error('演示模式：提交接口未完全开放');
        })
        .finally(() => {
          this.loading = false;
        });
    },
    resetForm() {
       this.form = {
        courseName: '',
        type: '选修',
        credit: 2,
        peoplecount: 50,
        wname: '',
        sse: ''
      };
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
</style>
