<template>
  <div>
    

    <div class="my-container" id="app" v-cloak>
      <HeaderBar title="채팅방 리스트" />
      <div class="row">
        <div class="title">
          <h1>채팅방 리스트</h1>
        </div>
      </div>

      <ul class="list-group">
        <!-- <router-link to="`/room/${item.roomUUID}`"></router-link> -->
        <li
          class="list-group-item list-group-item-action"
          v-for="item in chatrooms"
          v-bind:key="item.id"
          v-on:click="enterRoom(item.id, item.groupName)"
          router-link
          to="/"
        >
        [{{item.category}}] {{ item.groupName }} 
          <!-- <router-link to="/">이름: {{ item }}</router-link> -->
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
// const API_URL = `http://localhost:8080`;
import HeaderBar from "@/components/HeaderBar";

export default {
  name: "RoomList",
  components: {
    HeaderBar,
  },
  props: {
    msg: String,
  },
  data: () => ({
    room_name: "",
    chatrooms: [],
  }),
  created() {
    // 초기화 시 가져오기
    this.findAllRoom();
  },

  watch: {
    // currentBranch가 변경될 때마다 데이터 다시 가져오기
    currentBranch: "fetchData",
  },

  methods: {
    findAllRoom() {
      this.$axios.get(`${this.$BASE_URL.chatting}/chat/room`, {
        headers: {
        Authorization: sessionStorage.getItem("userId")
        }
      }
      ).then((response) => {
        console.log(response.data);
        const room = response.data;

        this.chatrooms = room;
        return room;
      });
    },

    createRoom() {
      if (this.room_name === "") {
        alert("방 제목을 입력해 주십시요.");
      } else {
        const room = { roomUUID: this.room_name };
        this.chatrooms.push(room);
        const params = new URLSearchParams();
        params.append("name", this.room_name);
        this.$axios
          .post("http://localhost:8080/chat/room", params)
          .then((response) => {
            alert(`${response.data.roomName}방 개설에 성공하였습니다.`);
            this.room_name = "";
            this.findAllRoom();
          })
          .catch((response) => {
            console.log(response);
            alert("채팅방 개설에 실패하였습니다.");
          });
      }
    },
    enterRoom(roomId, groupName) {

        const nickname = sessionStorage.getItem("userNickname")
        const userId = sessionStorage.getItem("userId")

        this.$router.push({
          name: "RoomDetail",
          params: { nickname, roomId, groupName, userId},
        });
      
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@import "https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css";
#div{
  text-align: center;
}
.container{
  width: 1400px;
  margin:auto;
}

.title{
  margin-top: 30px;
  margin-bottom: 10px;
}

.list-group{
  font-size: 23px
}

.my-container{
  margin: auto;
}
@media (min-width: 800px){ /*if size> 650 do*/
  .my-container{
    width:800px;
    
  }
}

@media (min-width: 1400px){ /*if size> 650 do*/
  .my-container{
    width:1350px;
  }
}

@media (max-width:650px){
  .my-container{
    width:90vw;
  }
}
</style>
