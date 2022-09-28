package com.spring.javagreenS.service;

import java.util.ArrayList;

import org.springframework.web.multipart.MultipartFile;

import com.spring.javagreenS.vo.MemberVO;

public interface MemberService {

	public MemberVO getMemIdCheck(String mid);

	public MemberVO getNickNameCheck(String nickName);

	public int setMemInputOk(MultipartFile fName, MemberVO vo);

	public void setMemberVisitProcess(MemberVO vo);

	public ArrayList<MemberVO> getMemList(int startIndexNo, int pageSize);

	public int setMemUpdateOk(MultipartFile fName, MemberVO vo);

	public void setMemDeleteOk(String mid);

	public void setPwdChange(String mid, String pwd);

	public MemberVO getMemIdEmailCheck(String mid, String toMail);

	public int totRecCnt();

	public MemberVO getMemEmailCheck(String email);

	public void setKakaoMemberInputOk(String mid, String pwd, String nickName, String email);

	public String getTodayVisitDate();

	public void setTodayVisitCountInsert();

	public void setTodayVisitCountUpdate(String strToday);

	public ArrayList<MemberVO> getAdminMemberLevelList(int startIndexNo, int pageSize, int level);

	public ArrayList<MemberVO> getAdminMemberMidList(int startIndexNo, int pageSize, String mid);

	public void setAdminLevelUpdate(int idx, int level);

}
