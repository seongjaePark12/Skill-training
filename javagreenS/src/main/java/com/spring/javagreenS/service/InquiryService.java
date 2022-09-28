package com.spring.javagreenS.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import com.spring.javagreenS.vo.InquiryReplyVO;
import com.spring.javagreenS.vo.InquiryVO;

public interface InquiryService {

	public List<InquiryVO> getInquiryList(int startIndexNo, int pageSize, String part, String mid);

	public void setInquiryInput(MultipartFile file, InquiryVO vo);

	public InquiryVO getInquiryView(int idx);

	public InquiryReplyVO getInquiryReply(int idx);

	public void setInquiryUpdate(MultipartFile file, InquiryVO vo);

	public void setInquiryDelete(int idx, String fSName);

}
