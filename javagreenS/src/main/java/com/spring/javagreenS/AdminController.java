package com.spring.javagreenS;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.javagreenS.pagination.PageProcess;
import com.spring.javagreenS.pagination.PageVO;
import com.spring.javagreenS.service.AdminService;
import com.spring.javagreenS.service.MemberService;
import com.spring.javagreenS.vo.InquiryReplyVO;
import com.spring.javagreenS.vo.InquiryVO;
import com.spring.javagreenS.vo.MemberVO;
import com.spring.javagreenS.vo.QrCodeVO;

@Controller
@RequestMapping("/admin")
public class AdminController {
	String msgFlag = "";
	
	@Autowired
	AdminService adminService;
	
	@Autowired
	PageProcess pageProcess;
	
	@Autowired
	MemberService memberService;
	
	
	@RequestMapping(value="/adMenu", method = RequestMethod.GET)
	public String adMenuGet() {
		return "admin/adMenu";
	}
	
	@RequestMapping(value="/adLeft", method = RequestMethod.GET)
	public String adLeftGet() {
		return "admin/adLeft";
	}
	
	@RequestMapping(value="/adContent", method = RequestMethod.GET)
	public String adContentGet(Model model) {
		return "admin/adContent";
	}
	
	@RequestMapping(value="/dbShop/dbCategory", method = RequestMethod.GET)
	public String dbCategoryGet(Model model) {
		return "admin/dbShop/dbCategory";
	}
	
	@RequestMapping(value="/adMemberList", method = RequestMethod.GET)
	public String adMemberListGet(
			@RequestParam(name="pag", defaultValue="1", required=false) int pag,
			@RequestParam(name="pageSize", defaultValue="5", required=false) int pageSize,
			@RequestParam(name="level", defaultValue="99", required=false) int level,
			@RequestParam(name="mid", defaultValue="", required=false) String mid,
			Model model) {
	  PageVO pageVo = null;
	  if(mid.equals("")) {
	  	pageVo = pageProcess.totRecCnt(pag, pageSize, "adminMemberList", "", level+"");	// ???????????? ?????? ??????
	  }
	  else {
	  	pageVo = pageProcess.totRecCnt(pag, pageSize, "adminMemberList", mid, "");	// ???????????? ??????
	  }
	  
	  ArrayList<MemberVO> vos = new ArrayList<MemberVO>();
	  if(mid.equals("")) {	// level??? ????????????
	  	vos = memberService.getAdminMemberLevelList(pageVo.getStartIndexNo(), pageSize, level);
	  }
	  else {								// ?????? id??? ????????????
	  	vos = memberService.getAdminMemberMidList(pageVo.getStartIndexNo(), pageSize, mid);
	  }
	  //System.out.println("pageVo : " +pageVo);
		model.addAttribute("vos", vos);
		model.addAttribute("level", level);
		model.addAttribute("mid", mid);
		model.addAttribute("pageVo", pageVo);
		model.addAttribute("totRecCnt", pageVo.getTotRecCnt());
		
		return "admin/member/adMemberList";
	}
	
	@ResponseBody
	@RequestMapping(value="/adMemberLevel", method = RequestMethod.POST)
	public String adMemberLevelPost(int idx, int level) {
		memberService.setAdminLevelUpdate(idx, level);
		return "";
	}
	
	/*
	@RequestMapping(value="/qrCode", method = RequestMethod.GET)
	public String qrCodeGet(Model model) {
		String[] qrCodes = adminService.getQrCode();
		model.addAttribute("qrCodes", qrCodes);
		
		return "admin/qrCode/qrCode";
	}
	*/
	
	// Qr Code ?????????????????? ?????? ?????? ????????????
	@RequestMapping(value="/qrCodeTicket", method = RequestMethod.GET)
	public String qrCodeTicketGet(
		@RequestParam(name="startJumun", defaultValue="", required=false) String startJumun,
    @RequestParam(name="endJumun", defaultValue="", required=false) String endJumun,
    @RequestParam(name="pag", defaultValue="1", required=false) int pag,
    @RequestParam(name="pageSize", defaultValue="5", required=false) int pageSize,
    Model model) {
			
		PageVO pageVo = null;
    pageVo = pageProcess.totRecCnt(pag, pageSize, "qrCodeTicket", startJumun, endJumun);
    pageVo.setStartJumun(startJumun);
    pageVo.setEndJumun(endJumun);
		
    ArrayList<QrCodeVO> vos = adminService.getQrCodeCondition(pageVo.getStartIndexNo(), pageSize, startJumun, endJumun);
    
    model.addAttribute("vos", vos);
	  model.addAttribute("pageVo", pageVo);
		
		return "admin/qrCode/qrCode";
	}
	
	// QR Code ??? ???????????? 1?????? ????????????
	@SuppressWarnings("deprecation")
	@ResponseBody
	@RequestMapping(value="/qrCodeDelete", method = RequestMethod.POST)
	public String qrCodeDeletePost(HttpServletRequest request, QrCodeVO vo) {
		String uploadPath = request.getRealPath("/resources/data/qrCode/");
		adminService.setQrCodeDelete(uploadPath, vo);
		return "";
	}
	
	// QR Code ???????????? ????????????
	@SuppressWarnings("deprecation")
	@ResponseBody
	@RequestMapping(value="/qrCodeTicket", method = RequestMethod.POST)
	public String qrCodeTicketPost(HttpServletRequest request, String delItems) {
		String uploadPath = request.getRealPath("/resources/data/qrCode/");
		
		String[] idxs = delItems.split("/");
		for(String idx : idxs) {
			adminService.setQrCodeSelectDelete(uploadPath, Integer.parseInt(idx));
		}
		return "";
	}
	
	// ???????????? ?????? ?????? ?????????
	@RequestMapping(value="/imsiFileDelete", method = RequestMethod.GET)
	public String imsiFileDeleteGet() {
		return "admin/file/tempDelete";
	}
	
	// ??????????????? ??????????????????
	@SuppressWarnings("deprecation")
	@ResponseBody
	@RequestMapping(value="/tempFileLoad", method = RequestMethod.POST)
	public String[] tempFileLoadPost(HttpServletRequest request, String folderName) throws IOException {
		String realPath = request.getRealPath("/resources/");
		
		if(folderName.equals("ckeditor")) {
			realPath += "data/ckeditor/";
		}
		else if(folderName.equals("dbShop")) {
			realPath += "data/dbShop/";
		}
		String[] files = new File(realPath).list();
		
		return files;
	}
	
  // ?????????????????? ???????????? ????????????
	@SuppressWarnings("deprecation")
	@ResponseBody
	@RequestMapping(value="/imsiFileDelete", method = RequestMethod.POST)
	public String tempFileLoadPost(HttpServletRequest request, String folderName, String delItems) {
		delItems = delItems.substring(0, delItems.length()-1);
		String uploadPath = request.getRealPath("/resources/data/") + folderName + "/";
		
		String[] fileNames = delItems.split("/");
		for(String fileName : fileNames) {
			String realPathFile = uploadPath + fileName;
			new File(realPathFile).delete();
		}
		return "";
	}
	
  // ????????? 1:1 ????????? ????????????
	@RequestMapping(value="/adInquiryList", method = RequestMethod.GET)
	public String adInquiryListGet(
			@RequestParam(name="part", defaultValue="??????", required=false) String part,
			@RequestParam(name="pag", defaultValue="1", required=false) int pag,
	    @RequestParam(name="pageSize", defaultValue="5", required=false) int pageSize,
			Model model) {
		PageVO pageVo = pageProcess.totRecCnt(pag, pageSize, "adminInquiry", part, "");
		
    ArrayList<QrCodeVO> vos = adminService.getInquiryListAdmin(pageVo.getStartIndexNo(), pageSize, part);
    
    model.addAttribute("vos", vos);
	  model.addAttribute("pageVo", pageVo);
	  model.addAttribute("part", part);
		
		return "admin/inquiry/adInquiryList";
	}
	
	// ????????? ???????????? ??? ????????????(???????????? ????????? ??????/??????????????????????????? ?????? ???????????? ??????.)
	@RequestMapping(value="/adInquiryReply", method = RequestMethod.GET)
	public String adInquiryReplyGet(int idx,
			@RequestParam(name="part", defaultValue="??????", required=false) String part,
			@RequestParam(name="pag", defaultValue="1", required=false) int pag,
	    @RequestParam(name="pageSize", defaultValue="5", required=false) int pageSize,
			Model model) {
		InquiryVO vo = adminService.getInquiryContent(idx);
		InquiryReplyVO reVo = adminService.getInquiryReplyContent(idx);
		model.addAttribute("part", part);
		model.addAttribute("pag", pag);
		model.addAttribute("vo", vo);
		model.addAttribute("reVo", reVo);
		return "admin/inquiry/adInquiryReply";
	}
	
	// ????????? ???????????? ????????????
	@ResponseBody
	@RequestMapping(value="/adInquiryReplyInput", method = RequestMethod.POST)
	public String adInquiryReplyInputPost(InquiryReplyVO vo, Model model) {
		adminService.setInquiryInputAdmin(vo);
		adminService.setInquiryUpdateAdmin(vo.getInquiryIdx());
		
		return "admin/inquiry/adInquiryReply";
	}
	
	// ????????? ????????? ????????????
	@ResponseBody
	@RequestMapping(value="/adInquiryReplyUpdate", method = RequestMethod.POST)
	public String adInquiryReplyUpdatePost(InquiryReplyVO reVo) {
		adminService.setInquiryReplyUpdate(reVo);	// ???????????? ???????????? ??????????????? ????????????
		return "";
	}
	
	// ????????? ????????? ????????????
	@ResponseBody
	@RequestMapping(value="/adInquiryReplyDelete", method = RequestMethod.POST)
	public String adInquiryReplyDeletePost(int reIdx) {
		adminService.setInquiryReplyDelete(reIdx);	// ???????????? ???????????? ??????????????? ????????????
		return "";
	}
	
}