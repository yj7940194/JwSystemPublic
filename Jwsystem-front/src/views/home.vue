<template>
  <div class="dashboard-container">
    <div class="dashboard-editor-container" v-if="qx == '管理员'">
      <div class="panel-card">
        <admin-panel />
      </div>
    </div>
    <div class="dashboard-editor-container" v-if="qx == '教务人员'">
      <div class="panel-card">
        <jw-panel />
      </div>
    </div>
    <div class="dashboard-editor-container" v-if="qx == '讲师' || qx == '教师' || qx == '院长'">
      <div class="panel-card">
        <teacher-panel />
      </div>
    </div>
    <div class="dashboard-editor-container" v-if="qx == '学生'">
      <div class="panel-card">
        <student-panel />
      </div>
    </div>
  </div>
</template>

<script>
import AdminPanel from './dashboard/AdminPanel'
import jwPanel from './dashboard/jw/jwPanel'
import studentPanel from './dashboard/student/studentPanel'
import teacherPanel from './dashboard/teacher/teacherPanel'

export default {
  name: 'Dashboard',
  data(){
    return{
      qx:null
    }
  },
  components: {
    AdminPanel,
    jwPanel,
    studentPanel,
    teacherPanel
  },
  created() {
      this.qx = this.$store.state.user.user.qx
  }
}
</script>

<style rel="stylesheet/scss" lang="scss" scoped>
  .dashboard-container {
    display: flex;
    flex-direction: column;
    min-height: calc(100vh - 84px);
    padding: 16px 20px 24px;
    background: #f5f7fa;
  }

  .dashboard-editor-container {
    flex: 1;
    padding: 0;
    margin: 0;
    min-height: 0; /* allow child to stretch */
  }

  .panel-card {
    height: 100%;
    background: #fff;
    padding: 16px;
    border-radius: 6px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    display: flex;
    flex-direction: column;
  }
</style>
