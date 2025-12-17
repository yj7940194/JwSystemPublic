<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>我的授课列表</span>
      </div>
      
      <div class="filter-container" style="margin-bottom: 20px;">
        <el-button type="primary" icon="el-icon-refresh" @click="loadData">刷新</el-button>
      </div>

      <el-table
        :data="dataList"
        v-loading="loading"
        border
        style="width: 100%">
        <el-table-column label="ID" prop="id" width="180" align="center"/>
        <el-table-column prop="name" label="课程名称" min-width="150" show-overflow-tooltip/>
        <el-table-column prop="credit" label="学分" width="80" align="center"/>
        <el-table-column prop="tname" label="学期" width="170" align="center" show-overflow-tooltip/>
        <el-table-column prop="time" label="上课时间" width="200">
           <template slot-scope="scope">
             {{ scope.row.wname }} {{ scope.row.sse }}
           </template>
        </el-table-column>
        <el-table-column prop="people" label="人数" width="80" align="center"/>
        <el-table-column prop="nname" label="性质" width="120" align="center" show-overflow-tooltip/>
        <el-table-column label="操作" width="150" align="center">
          <template slot-scope="scope">
             <el-button type="text" size="small" @click="$router.push({path: '/teacher/score', query: {courseId: scope.row.id}})">录入成绩</el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          background
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="query.page"
          :page-sizes="[10, 20, 50]"
          :page-size="query.size"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total">
        </el-pagination>
      </div>
    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "TeacherCourse",
  data() {
    return {
      dataList: [],
      loading: false,
      total: 0,
      query: {
        page: 1,
        size: 10
      }
    };
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      // 后端分页参数为 offset/limit（对应 MyBatisPlus Page(current,size)）
      const params = { offset: this.query.page, limit: this.query.size }
      request.get('/api/course/findCourseByteacherId', { params })
        .then(res => {
          // TableResponse { total, rows }
          if (res && res.rows) {
             this.dataList = res.rows;
             this.total = Number(res.total) || 0;
          } else {
             this.dataList = [];
             this.total = 0;
          }
        })
        .catch(err => {
          console.error(err);
          this.$message.error('获取课程失败');
        })
        .finally(() => {
          this.loading = false;
        });
    },
    handleSizeChange(val) {
      this.query.size = val;
      this.loadData();
    },
    handleCurrentChange(val) {
      this.query.page = val;
      this.loadData();
    }
  }
};
</script>

<style scoped>
.app-container {
  padding: 20px;
}
.pagination-container {
  margin-top: 20px;
  text-align: right;
}
</style>
