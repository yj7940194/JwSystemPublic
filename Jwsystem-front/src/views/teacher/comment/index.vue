<template>
  <div class="app-container">
    <el-card>
      <div slot="header">
        <span>学生评教列表</span>
      </div>
      
      <el-alert title="查看学生的匿名评价反馈" type="info" :closable="false" style="margin-bottom: 20px"/>

      <el-table
        :data="dataList"
        v-loading="loading"
        border
        style="width: 100%">
        <el-table-column label="序号" type="index" width="60" align="center"/>
        <el-table-column prop="courseName" label="课程名称" width="200"/>
        <el-table-column prop="score" label="评分" width="150" align="center">
          <template slot-scope="scope">
             <el-rate v-model="scope.row.score" disabled show-score text-color="#ff9900"></el-rate>
          </template>
        </el-table-column>
        <el-table-column prop="comment" label="评价内容" min-width="300" show-overflow-tooltip/>
        <el-table-column prop="createTime" label="评价时间" width="180" align="center">
           <template slot-scope="scope">
             {{ scope.row.createTime | parseTime }}
           </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination
          background
          @current-change="loadData"
          :current-page="query.page"
          :page-size="query.size"
          layout="total, prev, pager, next"
          :total="total">
        </el-pagination>
      </div>

    </el-card>
  </div>
</template>

<script>
import request from '@/utils/request'
export default {
  name: "TeacherComment",
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
  filters: {
    parseTime(time) {
      if (!time) return '';
      return new Date(time).toLocaleString();
    }
  },
  mounted() {
    this.loadData();
  },
  methods: {
    loadData() {
      this.loading = true;
      request.get('/api/comment/queryCourseComment', { params: this.query })
        .then(res => {
           // Check structure
           if (res.data && res.data.rows) {
             this.dataList = res.data.rows;
             this.total = res.data.total;
           } else {
             this.dataList = [];
           }
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
.pagination-container {
  margin-top: 20px;
  text-align: right;
}
</style>
