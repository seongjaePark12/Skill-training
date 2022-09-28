/* notify.sql */
create table notify (
  idx     int not null auto_increment primary key,	/* 공지사항 고유번호 */
  name    varchar(20)  not null,										/* 공지사항 올린이 */
  title   varchar(100) not null,										/* 공지사항 제목 */
  content text not null,														/* 공지사항 상세내역 */
  startDate datetime default now(),									/* 공지사항 알림 시작일 */
  endDate   datetime default now(),									/* 공지사항 알림 종료일 */
  popupSw   char(1)  default 'N'										/* 공지사항 초기화면에 개시여부 */
);

/* 대분류(categoryMain) */
create table categoryMain (
  categoryMainCode  char(1)  not null,				/* 대분류코드(A,B,C,... => 영문 대문자 1자 */
  categoryMainName  varchar(20) not null,			/* 대분류명(회사명... => 삼성/현대/LG) */
  primary key(categoryMainCode),
  unique key(categoryMainName)
);

/* 중분류(categoryMiddle) */
create table categoryMiddle (
  categoryMainCode   char(1)  not null,				/* 대분류코드를 외래키로 지정 */
  categoryMiddleCode char(2)  not null,				/* 중분류코드(01,02,03,... => 숫자 2자리를 문자형태로) */
  categoryMiddleName varchar(20) not null,		/* 중분류명(제품분류 - 전자제품/의류/신발류) */
  primary key(categoryMiddleCode),
  /* unique key(categoryMiddleName), */
  foreign key(categoryMainCode) references categoryMain(categoryMainCode)
  /* on update cascade on delete restrict */
);

/* 소분류(categorySub) */
create table categorySub (
  categoryMainCode    char(1) not null,			/* 대분류코드를 외래키로 지정 */
  categoryMiddleCode  char(2) not null,			/* 중분류코드를 외래키로 지정 */
  categorySubCode			char(3) not null,			/* 소분류코드(001,002,003,... => 숫자 3자리를 문자형으로) */
  categorySubName			varchar(20) not null,	/* 소분류명(상품구분 - 냉장고/에어컨/오디오/TV */
  primary key(categorySubCode),
  /* unique key(categorySubName), */
  foreign key(categoryMainCode)   references categoryMain(categoryMainCode),
  foreign key(categoryMiddleCode) references categoryMiddle(categoryMiddleCode)
);

/* 상품 테이블(dbProduct) */
create table dbProduct (
  idx  int  not null,											/* 상품 고유번호 */
  categoryMainCode   char(1)  not null,		/* 대분류코드 외래키지정 */
  categoryMiddleCode char(2)  not null,		/* 중분류코드 외래키지정 */
  categorySubCode    char(3)  not null,		/* 소분류코드 외래키지정 */
  productCode varchar(20)  not null,			/* 상품고유코드(대분류코드+중분류코드+소분류코드+고유번호) */
  productName	varchar(50)  not null,			/* 상품명(상품코드-모델명) - 세분류 */
  detail			varchar(100) not null,			/* 상품의 간단설명(초기화면 출력) */
  mainPrice		int not null,								/* 상품의 기본가격 */
  fName				varchar(100)	 not null,		/* 상품 기본사진(1장만 처리)-필수입력 */
  fSName			varchar(100) not null,			/* 서버에 저장될 상품의 고유파일이름 */
  content			text not null,							/* 상품의 상세설명 - ckeditor를 이용한 이미지 처리 */
  primary key(idx, productCode),
  foreign key(categoryMainCode)   references categorySub(categoryMainCode),
  foreign key(categoryMiddleCode) references categorySub(categoryMiddleCode),
  foreign key(categorySubCode)    references categorySub(categorySubCode)
);

/* 상품 옵션(dbOption) */
create table dbOption (
  idx 			  int not null auto_increment,/* 옵션 고유번호 */
  productIdx  int  not null,							/* dbProduct테이블의 고유번호 */
  optionName  varchar(50)  not null,			/* 옵션 이름 */
  optionPrice int not null default 0,			/* 옵션 가격 */
  primary key(idx),
  foreign key(productIdx) references dbProduct(idx)
);

/* 장바구니 테이블 */
create table dbCartList (
  idx   int not null auto_increment,			/* 장바구니 고유번호 */
  cartDate datetime default now(),				/* 장바구니에 상품을 담은 날짜 */
  mid   varchar(20) not null,							/* 장바구니를 사용한 사용자의 아이디 - 로그인한 회원 아이디이다. */
  productIdx  int not null,								/* 장바구니에 구입한 상품의 고유번호 */
  productName varchar(50) not null,				/* 장바구니에 담은 구입한 상품명 */
  mainPrice   int not null,								/* 메인상품의 기본 가격 */
  thumbImg		varchar(100) not null,			/* 서버에 저장된 상품의 메인 이미지 */
  optionIdx	  varchar(50)	 not null,			/* 옵션의 고유번호리스트(여러개가 될수 있기에 문자열 배열로 처리한다.) */
  optionName  varchar(100) not null,			/* 옵션명 리스트(배열처리) */
  optionPrice varchar(100) not null,			/* 옵션가격 리스트(배열처리) */
  optionNum		varchar(50)  not null,			/* 옵션수량 리스트(배열처리) */
  totalPrice  int not null,								/* 구매한 모든 항목(상품과 옵션포함)에 따른 총 가격 */
  primary key(idx, mid),
  foreign key(productIdx) references dbProduct(idx) on update cascade on delete restrict
  /* foreign key(mid) references member(mid) on update cascade on delete cascade */		/* 문자 외래키(mid)는 버전에 따라 오류발생 */
);

/* 주문 테이블 -  */
create table dbOrder (
  idx         int not null auto_increment, /* 고유번호 */
  orderIdx    varchar(15) not null,   /* 주문 고유번호(새롭게 만들어 주어야 한다.) */
  mid         varchar(20) not null,   /* 주문자 ID */
  productIdx  int not null,           /* 상품 고유번호 */
  orderDate   datetime default now(), /* 실제 주문을 한 날짜 */
  productName varchar(50) not null,   /* 상품명 */
  mainPrice   int not null,				    /* 메인 상품 가격 */
  thumbImg    varchar(100) not null,   /* 썸네일(서버에 저장된 메인상품 이미지) */
  optionName  varchar(100) not null,  /* 옵션명    리스트 -배열로 넘어온다- */
  optionPrice varchar(100) not null,  /* 옵션가격  리스트 -배열로 넘어온다- */
  optionNum   varchar(50)  not null,  /* 옵션수량  리스트 -배열로 넘어온다- */
  totalPrice  int not null,					  /* 구매한 상품 항목(상품과 옵션포함)에 따른 총 가격 */
  /* cartIdx     int not null,	*/		/* 카트(장바구니)의 고유번호 */ 
  primary key(idx, orderIdx),
  /* foreign key(mid) references member(mid), */		/* 문자인경우 외래키 고려~~~ */
  foreign key(productIdx) references dbProduct(idx)  on update cascade on delete cascade
);

/* 배송테이블 */
create table dbBaesong (
  idx     int not null auto_increment,
  oIdx    int not null,								/* 주문테이블의 고유번호를 외래키로 지정함 */
  orderIdx    varchar(15) not null,   /* 주문 고유번호 */
  orderTotalPrice int     not null,   /* 주문한 모든 상품의 총 가격 */
  mid         varchar(20) not null,   /* 회원 아이디 */
  name				varchar(20) not null,   /* 배송지 받는사람 이름 */
  address     varchar(100) not null,  /* 배송지 (우편번호)주소 */
  tel					varchar(15),						/* 받는사람 전화번호 */
  message     varchar(100),						/* 배송시 요청사항 */
  payment			varchar(10)  not null,	/* 결재도구 */
  payMethod   varchar(50)  not null,  /* 결재도구에 따른 방법(카드번호) */
  orderStatus varchar(10)  not null default '결제완료', /* 주문순서(결제완료->배송중->배송완료->구매완료) */
  primary key(idx),
  foreign key(oIdx) references dbOrder(idx) on update cascade on delete cascade
);

create table board (
  idx  int  not null auto_increment,	/* 게시글의 고유번호 */
  nickName  varchar(20)  not null,		/* 게시글을 올린사람의 닉네임 */
  title			varchar(100) not null,		/* 게시글의 글 제목 */
  email			varchar(100),							/* 글쓴이의 메일주소 */
  homePage	varchar(100),							/* 글쓴이의 홈페이지(블로그)주소 */
  content		text not null,						/* 글 내용 */
  wDate			datetime default now(),		/* 글 올린 날짜 */
  readNum		int default 0,						/* 글 조회수 */
  hostIp		varchar(50) not null,			/* 접속 IP 주소 */
  good			int default 0,						/* '좋아요' 횟수 누적처리 */
  mid				varchar(20) not null,			/* 회원 아이디(게시글 조회시 사용) */
  primary key(idx)										/* 게시판의 기본키 : 고유번호 */
);

/* 댓글 테이블(boardReply) */
create table boardReply (
  idx		int not null auto_increment,	/* 댓글의 고유번호 */
  boardIdx int not null,							/* 원본글의 고유번호(외래키로 지정함) */
  mid      varchar(20) not null,			/* 댓글 올린이의 아이디 */
  nickName varchar(20) not null,			/* 댓글 올린이의 닉네임 */
  wDate    datetime default now(),		/* 댓글쓴 날짜 */
  hostIp   varchar(50) not null,			/* 댓글쓴 PC의 IP */
  content  text				 not null,			/* 댓글 내용 */
  level    int  not null default 0,		/* 댓글레벨 - 부모댓글의 레벨은 0 */
  levelOrder int not null default 0,	/* 댓글의 순서 - 부모댓글의 levelOrder은 0 */
  primary key(idx),										/* 주키(기본키)는 idx */
  foreign key(boardIdx) references board(idx)	/* board테이블의 idx를 boardReply테이블의 외래키(boardIdx)로 설정했다. */
  /* on update cascade				원본테이블에서의 주키의 변경에 영향을 받는다. */
  /* on delete restrict			원본테이블에서의 주키삭제 시키지 못하게 한다.(삭제시는 에러발생하고 원본키를 삭제하지 못함.) */
);

/* unique : 필드가 서로 다른 값을 갖도록 함.(중복할 수 없도록 제약조건설정시 사용) */
create table testStudent (
  idx  int  not null auto_increment,
  hakbun int not null unique,
  mid  varchar(20) not null unique,
  name varchar(20) not null,
  age  int default 20,  
  primary key(idx,hakbun,mid)
);

create table guest (
	idx	  int not null auto_increment primary key,/* 방명록 고유번호 */
	name  varchar(20) not null,										/* 방문자 성명 */
	email varchar(60),														/* 이메일 주소 */
	homepage varchar(60),													/* 방문자의 홈페이지(블로그 주소) */
	vDate		datetime default now(),								/* 방문일자/시간 */
	hostIp	varchar(50) not null,									/* 방문자 IP */
	content text not null													/* 방문 소감 */
);

/* 1 : 1 문의 */
CREATE TABLE inquiry (
	idx INT NOT NULL AUTO_INCREMENT,						/* 고유번호 */
	mid VARCHAR(20) NOT NULL,										/* 아이디 */
	title VARCHAR(100) NOT NULL,								/* 1:1 문의 제목 */
	part VARCHAR(20) NOT NULL,									/* 분류(카테고리) */
	wDate DATETIME NOT NULL DEFAULT now(),			/* 문의쓴 날짜 */
	jumunNo varchar(50),																		/* 주문번호(구입후 문의 있을때) */
	content TEXT NOT NULL,											/* 문의 내역 */
	fName varchar(100),													/* 문의시에 올린 사진이나 문서파일 */
	fSName varchar(200),												/* 문의시에 올린 서버에 저장된 사진이나 문서파일 - 여기선 사진,압축파일만 올리도록처리함 */
	reply varchar(10) DEFAULT '답변대기중',				/* 답변 여부(답변대기중/답변완료) */
	PRIMARY KEY (idx)													/* 주키 : 고유번호 */
  /* FOREIGN KEY (mid) REFERENCES member(mid) ON UPDATE CASCADE ON DELETE CASCADE */	/* 외래키 : 회원 아이디 */
);

/* 1 : 1 문의 답변글 */
CREATE TABLE inquiryReply (
	reIdx 		INT NOT NULL AUTO_INCREMENT,
	inquiryIdx 		INT NOT NULL ,
	reWDate 		DATETIME NOT NULL DEFAULT now(),
	reContent	TEXT NOT NULL,
	PRIMARY KEY (reIdx),
  FOREIGN KEY (inquiryIdx) REFERENCES inquiry(idx)
);

create table member (
  idx		int not null auto_increment,	/* 회원 고유번호 */
  mid		varchar(20) not null,					/* 회원 아이디(중복불허) */
  pwd		varchar(100) not null,				/* 비밀번호(암호화처리) */
  nickName	varchar(20) not null,			/* 별명(중복불허) */
  name			varchar(20) not null,			/* 회원 성명 */
  gender		varchar(5)  default '남자',/* 성별 */
  birthday	datetime		default now(),/* 생일 */
  tel				varchar(15),							/* 전화번호(010-1234-5678) */
  address   varchar(100),							/* 주소 */
  email			varchar(50) not null,			/* 이메일(아이디/비밀번호 분실시 필요)-형식 체크할것 */
  homePage  varchar(50),							/* 홈페이지(블로그) 주소 */
  job				varchar(20),							/* 직업 */
  hobby			varchar(60),							/* 취미 */
  photo			varchar(100) default 'noimage.jpg',	/* 회원사진 */
  content		text,											/* 자기소개 */
  userInfor char(6) default '공개', 		/* 회원 정보 공개여부(공개/비공개) */
  userDel   char(2) default 'NO',			/* 회원 탈퇴 신청 여부(OK:탈퇴신청한회원, NO:현재가입중인회원) */
  point			int default 100,					/* 회원가입포인트(최초 100, 방문시마다 1포인트 증가) */
  level 		int default 1,						/* 4:준회원, 3:정회원, 2:우수회원 (1:운영자) 0:관리자 */
  visitCnt 	int default 0,						/* 방문횟수 */
  startDate datetime default now(),		/* 최초 가입일 */
  lastDate 	datetime default now(),		/* 마지막 접속일 */
  todayCnt	int default 0,						/* 오늘 방문한 횟수 */
  primary key(idx, mid)
);


create table pds (
  idx  int not null auto_increment,	/* 자료실 고유번호 */
  mid  varchar(20) not null,					/* 올린이 아이디 */
  nickName 	varchar(20) not null,		/* 올린이 닉네임 */
  fName			varchar(200) not null,	/* 처음 업로드할때의 파일명 */
  fSName		varchar(200) not null,	/* 파일서버에 저장되는 실제파일명 */
  fSize			int,										/* 총 파일 사이즈 */
  title			varchar(100) not null,	/* 파일 제목 */
  part			varchar(20)  not null,	/* 파일 분류 */
  pwd				varchar(100) not null,	/* 비밀번호(암호화 - SHA-256암호화 처리) */
  fDate  		datetime default now(),	/* 파일 업로드한 날짜 */
  downNum		int default 0,					/* 파일 다운로드 횟수 */
  openSw		char(6) default '공개',	/* 파일 공개(비공개)여부 */
  content		text,										/* 파일 상세설명 */
  primary key (idx)									/* 기본키 : 자료파일의 고유번호 */
);

create table qna (
  idx		int not null,										/* qna의 고유번호 */
  qnaIdx varchar(10) not null,					/* 답변글의 고유번호 */
  name  varchar(20)  not null,					/* qna 올린사람의 닉네임 */
  title varchar(100) not null,					/* qna의 글 제목 */
  email varchar(50)  not null,					/* 이메일 */
  pwd 	varchar(20),										/* 비밀번호(필요없음... 여기선 비밀'질문/답변'글의 용도로 사용할것, 즉 체크박스에 비밀글로 체크하면 여기선 이곳에 '1234'를 저장했다.) */
  wDate datetime	 default now(),				/* 글쓴날짜 */
  content text  not null,								/* qna 글내용 */
  qnaSw		varchar(2) 	not null default 'q',	/* question(q)인지 answer(a)인지 표시처리 */
  primary key(idx)											/* 기본키는 고유번호 */
);

create table schedule (
  idx    int         not null  auto_increment primary key,
  mid    varchar(20) not null,
  sDate datetime    not null,     /* 일정등록날짜 */
  part varchar(10) not null,			/* 1.모임, 2.업무, 3.학습, 4.여행, 0:기타 */
  content text not null						/* 일정 상세 내역 */
);

/* 대분류 */
create table goods1 (
  product1 varchar(50) not null primary key  	/* 대분류명 */
);

/* 중분류 */
create table goods2 (
  product1 varchar(50) not null,							/* 대분류명 */
  product2 varchar(50) not null primary key,	/* 중분류명 */
  foreign key(product1) references goods1(product1)
  /* on update cascade on delete restrict */
);

/* 소분류 */
create table goods3 (
  idx 		 int not null auto_increment primary key,
  product1 varchar(50) not null,							/* 대분류명 */
  product2 varchar(50) not null,							/* 중분류명 */
  product3 varchar(50) not null,							/* 소분류명 */
  foreign key(product1) references goods1(product1),
  foreign key(product2) references goods2(product2)
  /* on update cascade on delete restrict */
);

create table product (
  idx   int not null  auto_increment primary key,
  product1 varchar(50) not null,							/* 대분류명 */
  product2 varchar(50) not null,							/* 중분류명 */
  product3 varchar(50) not null,							/* 소분류명 */
  product	varchar(100) not null unique,				/* 상품명 */
  price   int not null,
  title   varchar(100),
  content text,
  foreign key(product1) references goods1(product1),
  foreign key(product2) references goods2(product2)
);

/* kakaoAddress : 지점 등록시켜놓고 검색하기 위한 테이블 */
create table kakaoAddress(
  address  varchar(50) not null,	/* 지점명 */
  latitude  double not null,			/* 위도 */
  longitude double not null				/* 경도 */
);

/* kakaoArea : 지역별로 테마구분별로 검색하기위해 사용한 테이블 */
create table kakaoArea(
  address1 varchar(30) not null, 	/* 도(경기도/강원도) */
  address2 varchar(30) not null, 	/* 시(강릉시/동해시) */
  latitude  double not null,			/* 위도 */
  longitude double not null				/* 경도 */
);

create table operator (
  oid  varchar(20) not null primary key,
  pwd  varchar(50) not null,
  name varchar(20) not null,
  keyIdx int not null
);

create table operatorHashTable2 (
  idx     int not null,
  hashKey char(8) not null
);

create table qrCode(
  idx  int not null auto_increment primary key,
  qrCode varchar(100) not null
);

create table person (
  idx int not null auto_increment primary key,
  mid varchar(20) not null,
  pwd varchar(20) not null
);

create table personDetail (
  mid varchar(5) not null,
  name varchar(20) not null,
  age  int default 20,
  address varchar(50) not null
);

