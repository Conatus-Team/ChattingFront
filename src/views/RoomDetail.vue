<template>
  <div v-cloak class="chatting_background">


    <div class="my-container" id="app" v-cloak>
      <div>
        <HeaderBar title="그룹 채팅방" />
     </div>
      <div class="chat">

        <div class="chat__header">
          <span class="chat__header__greetings">
            {{ groupName }}
          </span>
        </div>

        <!-- 채팅 메시지 -->
        <div
          class="chat__body"
          id="chat__body"
          @scroll="handleNotificationListScroll"
          ref="toolbarChat"
        >

          <!-- 
          지난 채팅메시지 더 불러오기-->
          <div v-if="this.last === true">
            <p>채팅방이 생성되었습니다</p>
          </div>

          <chat-message
            v-for="(message, index) in messages"
            :key="index"
            :msg="message"
            :prev="[index == 0 ? null : messages[index - 1]]"
          >
          </chat-message>
        </div>
        <!-- 채팅 메시지 끝 -->


        <div class="form">
          <input
            class="form__input"
            type="text"
            placeholder="메세지를 입력하세요."
            v-model.trim="message"
            @keyup.enter="sendMessage"
          />
          <div @click="sendMessage" class="form__submit">
            <svg
              width="30"
              height="30"
              viewBox="0 0 68 68"
              fill="#CCCCCC"
              xmlns="http://www.w3.org/2000/svg"
            >
              <g clip-path="url(#clip0_26_10)">
                <path
                  fill-rule="evenodd"
                  clip-rule="evenodd"
                  d="M48.0833 19.799C48.619 20.3347 48.806 21.127 48.5665 21.8457L35.8385 60.0294C35.5946 60.7614 34.9513 61.2877 34.1855 61.382C33.4198 61.4763 32.6681 61.1217 32.2539 60.4707L22.593 45.2893L7.41158 35.6285C6.76065 35.2142 6.40604 34.4625 6.50031 33.6968C6.59458 32.931 7.12092 32.2878 7.85287 32.0438L46.0366 19.3159C46.7553 19.0763 47.5476 19.2633 48.0833 19.799ZM26.5903 44.1204L33.3726 54.7782L42.0926 28.6181L26.5903 44.1204ZM39.2642 25.7897L23.7619 41.292L13.1041 34.5097L39.2642 25.7897Z"
                  fill=""
                />
              </g>
              <defs>
                <clipPath id="clip0_26_10">
                  <rect
                    width="48"
                    height="48"
                    fill="white"
                    transform="translate(33.9412) rotate(45)"
                  />
                </clipPath>
              </defs>
            </svg>
          </div>
        </div>
        <!-- 내용 입력 끝 -->
      </div>
    </div>
  </div>
</template>

<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.1.2/sockjs.min.js"></script> -->
<!-- <script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script> -->
<script>
// alert(document.title);
// websocket & stomp initialize
import Stomp from "webstomp-client";
import SockJS from "sockjs-client";
import HeaderBar from "@/components/HeaderBar";
import ChatMessage from "@/components/ChatMessage";
import { BASE_URL } from "./../constants/baseUrl";
// import lodash from "lodash";
// const HOST = "http://localhost:8081";
const HOST = BASE_URL.chatting;

// let sock = new SockJS(HOST + "/ws/chat");
// let ws = Stomp.over(sock);
let sock;
let ws;
let reconnect = 0;
// vue.js
export default {
  name: "RoomDetail",
  components: {
    HeaderBar,
    ChatMessage,
  },
  data() {
    return {
      roomId: 0,
      groupName: "",
      room: {},
      nickname: "나",
      message: "",
      messages: [],
      userId: 0,

      size: 10,
      page: 0,
      first: true,
      last: false,
      totalElements: 0,
      totalPages: 1,
      loading: false,
      sortBy: "id",
      sortDesc: false,
      sortDirection: "desc",

      useScrollListener: false,
    };
  },
  mounted() {

    this.findChatDataHistory();
    this.scrollDown();
    console.log(HOST);
    sock = new SockJS(`${HOST}/ws/chat`);
    ws = Stomp.over(sock);
    this.connect(this.roomId, this.nickname);
  },
  async created() {
    this.roomId = this.$route.params.roomId;
    this.groupName = this.$route.params.groupName;  
    if (!this.groupName ){
      this.getGroupName()
    }




    this.userId = sessionStorage.getItem("userId");
    if (this.$route.params.nickname) {
      this.nickname = this.$route.params.nickname;
    }
    this.findRoom();
  },

  methods: {
    getGroupName(){
      this.$axios
        .get(
          // `http://localhost:8080/chat/data/get/pagesort?page=${this.page}&size=${this.size}`
          `${HOST}/chattingRooms/${this.roomId}`
        )
        .then((response) => {
          this.groupName = response.data.groupName;
        })
    },
    scrollDown() {
      // 스크롤 아래로 (부드럽게)
      setTimeout(() => {
        const element = document.getElementById("chat__body");
        element.scrollTop = element.scrollHeight;

      }, 0);

      // // 스크롤 아래로 (바로)
      // const element = document.getElementById("chat__body");
      // element.scrollTop = element.scrollHeight;
    },
    findChatDataHistory() {
      this.$axios
        .get(
          // `http://localhost:8080/chat/data/get/pagesort?page=${this.page}&size=${this.size}`
          `${HOST}/chat/message/pagesort?roomId=${this.roomId}&page=${this.page}&size=${this.size}&sortOrder=${this.sortDirection}`
        )
        .then((response) => {
          console.log("axios response");
          console.log(response);
          const content = response.data.content;
          this.first = response.data.first;
          this.last = response.data.last;
          // console.log(content);
          // this.messages = lodash.cloneDeep(content);
          content.map((item) => {
            this.messages.unshift({ nickname: item.nickname, message: item.message });


          });
          console.log(this.messages);

          setTimeout(() => {
            const element = document.getElementById("chat__body");
            element.scrollTop = element.scrollHeight;
            this.useScrollListener= true
          }, 10);

        });
    },
    recvMessage(recv) {
      console.log(`recvMessage:`)
      console.log(recv)

      if (recv.type !== "ENTER")
      this.messages.push({
        type: recv.type,
        nickname: recv.type === "ENTER" ? "[알림]" : recv.nickname,
        message: recv.type === "ENTER" ? "" : recv.message,
      });

      //   this.messages.push({
      //     type: recv.type,
      //     nickname: recv.type == "ENTER" ? "[알림]" : recv.nickname,
      //     message: recv.message,
      //   });
      // 스크롤 아래로
      // setTimeout(() => {
      //   const element = document.getElementById("chat__body");
      //   element.scrollTop = element.scrollHeight;
      // }, 0);
      this.scrollDown();
    },
    connect(roomId, nickname) {
      // pub/sub event
      ws.connect(
        {},
        (frame) => {
          console.log("소켓연결성공");
          console.log(frame);
          ws.subscribe(`/topic/chat/room/${roomId}`, (chatMessage) => {
            const recv = JSON.parse(chatMessage.body);
            this.recvMessage(recv);
          });
          ws.send(
            "/app/chat/message",
            JSON.stringify({
              type: "ENTER",
              roomId,
              nickname,
              userId: this.userId,
            }),
            {}
          );
        },
        (error) => {
          console.log(error);
          // eslint-disable-next-line no-plusplus
          if (reconnect++ <= 5) {
            setTimeout(function () {
              console.log("connection reconnect");
              sock = new SockJS("/ws/chat");
              ws = Stomp.over(sock);
              this.connect();
            }, 10 * 1000);
          }
        }
      );
    },
    findRoom() {
      this.$axios.get(`${HOST}/chattingRooms/${this.roomId}`).then((response) => {
        this.room = response.data;
      });
    },
    sendMessage() {
      if (this.message === "") {
        return;
      }
      console.log(`Send message:${this.message}`);
      ws.send(
        "/app/chat/message",

        JSON.stringify({
          type: "TALK",
          roomId: this.roomId,
          nickname: this.nickname,
          message: this.message,
          userId: this.userId,
        }),
        {}
      );
      this.message = "";
    },
    handleNotificationListScroll(e) {
      if (!this.useScrollListener) return;
      const { scrollHeight, scrollTop, clientHeight } = e.target;
      // const { scrollTop, scrollHeight } = e.target;
      const isAtTheBottom = scrollHeight === scrollTop + clientHeight;
      // // 일정 한도 밑으로 내려오면 함수 실행
      if (isAtTheBottom) this.handleLoadMore();

      // console.log(`${scrollTop}, ${scrollHeight}`);
      const isAtTop = scrollTop === 0;

      if (isAtTop && this.last !== true) {
        // 페이징
        this.page = this.page + 1;

        this.$axios
          .get(
            // `http://localhost:8080/chat/data/get/pagesort?page=${this.page}&size=${this.size}`
            `${HOST}/chat/message/pagesort?roomId=${this.roomId}&page=${this.page}&size=${this.size}&sortOrder=${this.sortDirection}`
          )
          .then((response) => {
            console.log("axios response");
            console.log(response);
            const content = response.data.content;
            this.first = response.data.first;
            this.last = response.data.last;
            // console.log(content);
            // this.messages = lodash.cloneDeep(content);



            // content.map((item) => {
            //   console.log({ nickname: item.nickname, message: item.message })
            //   this.messages.unshift({ nickname: item.nickname, message: item.message });
            // });
            for (let i = 0; i < content.length; i++){
              console.log(i)
              this.messages.unshift({ nickname: content[i].nickname, message: content[i].message });
            }
            console.log("스크롤")
            // setTimeout(() => {
            //   const element = document.getElementById("chat__body");
            //   element.scrollTop = element.scrollHeight- scrollHeight;
            // }, 0);
            const element = document.getElementById("chat__body");
            // element.scrollTop = element.scrollHeight - scrollHeight;
            // setTimeout(() => {}, 0);
            // this.$refs.toolbarChat.scrollTop = element.scrollHeight - scrollHeight;
            // this.$el.scrollTop = element.scrollHeight - scrollHeight;

            
        //     this.$refs.scrollTo(element.scrollHeight - scrollHeight, {duration:0});
            this.$nextTick(() => {
            // this.$refs.toolbarChat.scrollTop = element.scrollHeight - scrollHeight;
            // document.getElementById("chat__body").scrollIntoView({behavior: "auto", block: "end", inline: "nearest"});
            document.getElementById("chat__body").scrollTo({
            top: element.scrollHeight - scrollHeight,
            left: 0,
            behavior: 'instant'
          });
        });
          });
      }
    },
  },
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
@import "https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css";
[v-cloak] {
  display: none;
}

li {
  text-align: left;
}

#align-right {
  text-align: right;
}

.container {
  /* display: flex;
  flex-direction: column;
  justify-content: space-between;

  height: 600px;
  background-color: #ffffff;
  margin: 5rem auto 0rem;
  border-radius: 1.5rem;
  box-shadow: 0px 1px 20px #9c9cc855; */
}

/* 채팅 바디 */
.chat {
  
  
  display: flex;
  flex-direction: column;
  justify-content: space-between;

  /* max-width: 375px; */
  height: 375px;
  background-color: #ffffff;
  /* margin: 5rem auto 0rem; */
  border-radius: 1.5rem;
  box-shadow: 0px 1px 20px #9c9cc855;
}

.chat__body {
  padding: 2rem;
  overflow: scroll;
  scroll-behavior: smooth;
}

.chat__body::-webkit-scrollbar {
  display: none;
}

.chat__header {
  background: #fdfdff;
  box-shadow: 0px 3px 10px rgba(0, 0, 0, 0.05);
  border-radius: 24px 24px 0px 0px;
  padding: 1.2rem;
  font-size: 25px;
  font-weight: 700;
  
}

.chat__header__greetings {
  color: #292929;
}

/* 입력폼 */
.form {
  display: flex;
  justify-content: space-between;
  padding: 1.4rem;
  background: #ffffff;
  border-radius: 30px 30px 24px 24px;
  box-shadow: 0px -5px 30px rgba(0, 0, 0, 0.05);
}

.form__input {
  border: none;
  padding: 0.5rem;
  font-size: 23px;
  width: calc(100% - 60px);
}

.form__input:focus {
  outline: none;
}

.form__submit {
  display: flex;
  align-items: center;
  cursor: pointer;
}

svg {
  transition: 0.3s;
}

svg:hover {
  fill: #999999;
}

.my-container{
  margin: auto;
}

/* 탭 */
@media (min-width: 800px){ /*if size> 650 do*/
  .my-container{
    width:800px;
    
  }
  .chat{
    height: 90vh;
  }
}

/* 웹 */
@media (min-width: 1400px){ /*if size> 650 do*/
  .my-container{
    width:1350px;
  }
  .chat{
    height: 90vh;
  }
}

/* 모바일 */
@media (max-width:650px){
  .app{
    width:100vw;
  }
  .my-container{
    width:90vw;
  }
  .chat{
    height: 90vh;
  }
}
</style>
