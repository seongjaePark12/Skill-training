/* 
   DATEDIFF(날짜1, 날짜2) : '날짜1 - 날짜2'의 결과를 반환한다.
   TIMESTAMPDIFF(단위, 날짜1, 날짜2) :  '날짜2 - 날짜1'의 결과를 반환한다.
     단위: YEAR(년)/QUARTER(분기)/MONTH(월)/WEEK(주)/DAY(일)/HOUR(시)/MINUTE(분)/SECOND(초)
   : 결과를 숫자로 반환한다.
*/
SELECT DATEDIFF('2022-06-22', '2022-06-01');
SELECT DATEDIFF(NOW(), '2022-06-01');

/* 'DATE_ADD'/'DATE_SUB' 결과를 날짜로 반환 */
SELECT DATE_ADD(NOW(), INTERVAL 1 DAY);
SELECT DATE_SUB(NOW(), INTERVAL 1 DAY);

SELECT * FROM board order by idx desc;
SELECT * FROM board WHERE wDate > DATE_SUB(NOW(), INTERVAL 2 DAY) order by idx desc;

SELECT TIMESTAMPDIFF(YEAR, '2022-06-23', '2022-06-22');
SELECT TIMESTAMPDIFF(MONTH, '2022-05-23', '2022-06-23');
SELECT TIMESTAMPDIFF(MONTH, '2022-06-22', '2022-06-23');
SELECT TIMESTAMPDIFF(MONTH, '2022-05-22', NOW());
SELECT TIMESTAMPDIFF(DAY, '2022-05-22', NOW());
SELECT TIMESTAMPDIFF(DAY, '2022-06-22', NOW());
SELECT TIMESTAMPDIFF(HOUR, '2022-06-22', NOW());
SELECT TIMESTAMPDIFF(MINUTE, '2022-06-22', NOW());
SELECT TIMESTAMPDIFF(MINUTE, '2022-06-22', NOW()) / 60;
SELECT TIMESTAMPDIFF(MINUTE, '2022-06-22', NOW()) / (60 * 24);

select *,cast(TIMESTAMPDIFF(MINUTE, wDate, NOW()) / 60 as signed integer) AS diffTime  from board order by idx desc limit 0,10;



/* 
  외래키(foreign key) : 서로다른 테이블간의 연관관계를 맺어주기위한 키
       : 외래키를 설정하려면, 설정하려는 외래키는 다른테이블의 주키(기본키 : Primary key)이어야 한다.
         즉, 외래키로 지정하는 필드는, 해당테이블의 속성과 똑 같아야 한다.
*/

/* sub query
    : 쿼리안에 쿼리를 삽입시키는 방법(위치는 상황에 따라서 사용자가 지정해준다.) - select 문과 함께 사용..
   예) select 필드명,(서브쿼리) from 테이블명 ~ where 조건절 ~~~ .....
       select 필드리스트 from (서브쿼리)~~ where 조건절 ~~~ .....
       select 필드리스트 from 테이블명 where (서브쿼리)~~ .....
 */

-- board 테이블의 목록 모두 보여주기(idx 역순으로, 출력 자료의 개수는 5개)
select * from board order by idx desc limit 5;
-- boardReply테이블의 구조?
desc boardReply;
-- board 테이블의 idx 37번글에 적혀있는 댓글(boardReply테이블)의 개수는? 
select count(*) from boardReply where boardIdx = 37;
-- board 테이블의 idx 37번글에 적혀있는 댓글(boardReply테이블)의 개수는?(단, 출력은 부모글의 고유번호와 댓글개수를 출력)
select boardIdx as 부모고유번호, count(*) from boardReply where boardIdx = 37;
-- board테이블의 고유번호가 37번 자료의 닉네임을 보여주시오.
select nickname from board where idx = 37;
-- board테이블 37번의 닉네임과 부모고유번호와, board 37번에 달려있는 댓글(boardReply)의 갯수를 출력?
select (select nickname from board where idx = 37) as 닉네임, boardIdx as 부모고유번호, count(*) from boardReply where boardIdx = 37;
-- board테이블의 37번 작성자의 아이디와, 현재글(부모글37번)에 달여있는 댓글(boardReply테이블) 사용자의 닉네임을 출력하시오?
select (select nickname from board where idx = 37) as 작성자아이디, nickname from boardReply where boardIdx=37;
select mid, (select nickname from boardReply where boardIdx = 37) as 작성자아이디 from board where idx=37;	/* 부모관점에서 보게되면 'where idx=37'의 결과는 1개만을 요구하기에 2개이상의 자료가 출력된다면 오류가 발생한다.   */
-- board테이블의 37번 작성자의 아이디와, 현재글(부모글37번)에 달여있는 댓글(boardReply테이블)의 개수를 출력하시오?
select mid,(select count(*) from boardReply where boardIdx=37) from board where idx=37;

-- 부모테이블(board)에있는 자료중 뒤에서 5개를 출력하되(아이디,닉네임), 부모테이블에 달여있는 댓글(boardReply테이블)의 수와 함께 출력하시오.
select idx,mid,nickName,(select count(*) from boardReply where boardIdx=board.idx) as replyCount from board order by idx desc limit 5;

select boardIdx from boardReply where boardIdx=37;
select * from board,boardReply where (select boardIdx from boardReply where boardIdx=board.idx)=idx order by idx desc limit 5;
select boardIdx from boardReply where (select mid from board)='b1234' order by idx desc limit 5;

// 최근글 출력연습
select count(*) from board where date_sub(now(), interval 1 day) < wDate;
select * from board where date_sub(now(), interval 1 day) < wDate order by idx desc limit 5;

select *,(select count(*) from boardReply where boardIdx=board.idx) as replyCount from board where date_sub(now(), interval 1 month) < wDate order by idx desc;

select date_sub(now(), interval 2 day);
SELECT DATE_SUB(NOW(), INTERVAL 1 MONTH);


/*
  - 테이블 설계시 제약조건(필드에 대한 제한) - constraint
    : 생성시에 설정(creat) , 생성후 변경(alter table)
  1. 필드의 값 허용유무? not null
  2. 필드의 값을 중복허용하지 않겠다? primary key , unique
  3. 필드의 참조유무(다른테이블에서)? foreign key
  4. 필드의 값에 기본값을 지정? default
  
  * primary key를 2개 이상 지정하면 primary key도 중복을 허용하게 된다.
  * 만약 2개 이상의 primary key에 중복을 허용하지 않으려면 unique로 설정해줘야 한다.
  * 2개의 primary key를 지정후 1개의 primary key에 unique를 설정하면, 두개의 primary key 모두 중복불허가 된다.
  * 3개의 primary key를 지정후 2개의 primary key에 unique를 설정하면, 세개의 primary key 모두 중복불허가 된다.(2개이상 unique지정하면 된다.)
*/

/* unique : 필드가 서로 다른 값을 갖도록 함.(중복할 수 없도록 제약조건설정시 사용) */
create table testStudent (
  idx  int  not null auto_increment,
  hakbun int not null unique,
  mid  varchar(20) not null unique,
  name varchar(20) not null,
  age  int default 20,  
  primary key(idx,hakbun,mid)
);

/* inquiry */
show tables;

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

/*
* DATEDIFF : 날짜 차이(2022-01-31)를 구하는 함수(날짜1 - 날짜2)
* 사용법 : DATEDIFF(날짜1, 날짜2)
* 사용예 :
SELECT DATEDIFF('2022-05-01', '2022-05-06');

* TIMESTAMPDIFF함수 : 날짜와 시간(2022-01-31 12:30:50) 차이를 구하는 함수(날짜2 - 날짜1)
* 사용법 : TIMESTAMPDIFF(날짜1, 날짜2)
* 단위 :
  초 : SECOND , 분 : MINUTE , 시 : HOUR
  일 : DAY , 월 : MONTH , 년 : YEAR
* 사용예 :
SELECT TIMESTAMPDIFF(DAY, '2022-05-01', '2022-05-06');
*/

/* 이번에 작성된 qna는 다음과 같은 방법으로 구현해 봤다.
 * 질문글과 답변글을 올릴때 아래 idx, qnaIdx, qnaSw가 결정된다. 즉, qnaSw는 질문글은 'q', 답변글은 'a'로 설정되고, 먼저 idx값을 구한후, 아래와 같은 방법으로 qnaIdx를 구한다.
 * 질문글 올릴때는, qnaIdx값을, 만들어진 idx값에 '_2'를 붙여서 등록시켜주고, 
 * 답변글을 올릴때는, 질문글의 qnaIdx값의 _앞의 고유번호를 받아와서 붙여주기 '_1'을 붙여서 등록시켜준다. 추후 계속되는 답변글은 계속해서 질문글의 qnaIdx값의 '_'앞의 고유번호에 '_1'을 똑같이 붙여준다. 출력시 qnaIdx내림차순출력값이 같으면 idx내림차순으로 출력하면된다.
 * 나중에 결과를 출력할때는 qnaIdx 내림차순으로 출력시켜주면 자동적으로 답변과 질문글이 정렬되어 출력된다. 이때 답변글은 '└'기호를 붙여서 들여쓰기 해 주었다. 
idx		qnaIdx	qnaSw
1			1_2			q
2			1_1			a
3			3_2			q
4			4_2			q
5			3_1			a
6			3_1  		a
7			7_2			q

아래처럼 정렬해서 결과를 출력시켜준다.
select * from qna2 order by qnaIdx desc, idx desc;
idx		qnaIdx	qnaSw
7			7_2			q
4			4_2			q
5			3_1			a
6			3_1  		a
3			3_2			q
2			1_1			a
1			1_2			q

*/

