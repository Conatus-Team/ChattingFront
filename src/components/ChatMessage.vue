<template>
  <div>
    <div
      v-if="msg.nickname === userNickname"
      class="chat__mymessage"
      :class="[isSame ? '' : 'chat__first']"
    >
      <!-- <p class="chat__yourmessage__time">23:38</p> -->
      <p class="chat__mymessage__paragraph">{{ msg.message }}</p>
    </div>
    <div v-else-if="msg.nickname === '[알림]'">
      <!-- <p class="chat__yourmessage__time">23:38</p> -->
      <p class="chat__system">{{ msg.message }}</p>
    </div>
    <div
      v-else
      class="chat__yourmessage"
      :class="[isSame ? '' : 'chat__first']"
    >
      <!-- <div class="chat__yourmessage__avartar">
        <img
          :src="avatar"
          alt=""
          v-if="!isSame"
          class="chat__yourmessage__img"
        />
      </div> -->
      <div>
        <div class = "chat__yourmessage">
          <div class="chat__yourmessage__user" v-if="!isSamePerson(msg, prev)">
          <p >
            {{ msg.nickname }} 
          </p>
        </div>
          <div class="chat__yourmessage__p">
          <p class="chat__yourmessage__paragraph">
            {{ msg.message }}
          </p>
          <!-- <p class="chat__yourmessage__time">23:38</p> -->
        </div>
        </div>

      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ["msg", "prev"],
  data() {
    return {
      isSame: false,
      userNickname: ""
      //   avatar: require("../assets/avatar.svg"),
    };
  },
  methods: {
    isSamePerson(msg, prev) {

      if (prev[0] === null) {
        return false;
      } else if (prev[0]?.nickname == msg?.nickname) {
        return true;
      } else {
        return false;
      }
    },
  },
  created() {
    this.userNickname = sessionStorage.getItem("userNickname");

    this.isSame = this.isSamePerson(this.msg, this.prev);
    // if (this.msg?.from.avatar) {
    //   this.avatar = this.msg?.from.avatar;
    // }
  },
  mounted(){
  }
};
</script>

<style>
.chat__mymessage {
  display: flex;
  justify-content: right;
  align-items: flex-end;
  margin: 0;
  min-height: 40px;
  line-break: anywhere;
}

.chat__mymessage__paragraph {
  margin: 0.4rem 0 0 1rem;
  border-radius: 20px 20px 0px 20px;
  /* max-width: 180px; */
  max-width: 40rem;
  background-color: #27877f;
  color: #ffffff;
  padding: 0.8rem;
  font-size: 23px;
}

/* .chat__first {
  margin-top: 2rem;
} */

.chat__yourmessage {
  display: flex;
  flex-direction: column;
}

.chat__yourmessage__avartar {
  width: 40px;
  margin-right: 1rem;
}

.chat__yourmessage__img {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
}

.chat__yourmessage__user {
  display: flex;
  
  font-size: 23px;
  font-weight: 700;
  color: #292929;
  margin-top: 20px;

  float: left;
  margin-bottom: -20px;
}

.chat__yourmessage__p {
  display: flex;
  align-items: flex-end;
  line-break: anywhere;
  /* margin-top: 22px; */
}

.chat__yourmessage__paragraph {
  margin: 0.4rem 1rem 0 0;
  border-radius: 0px 20px 20px 20px;
  background-color: #f3f3f3;
  /* max-width: 180px; */
  max-width: 40rem;
  color: #414141;
  padding: 0.8rem;
  font-size: 23px;
  /* margin-top:1px; */
}

.chat__yourmessage__time {
  margin: 0;
  font-size: 12px;
  color: #9c9c9c;
}

.chat__system {
}
</style>
