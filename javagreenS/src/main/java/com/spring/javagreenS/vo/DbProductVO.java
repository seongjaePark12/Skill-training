package com.spring.javagreenS.vo;

import lombok.Data;

@Data
public class DbProductVO {
	private int idx;
	private String productCode;
	private String productName;
	private String detail;
	private String mainPrice;
	private String fName;
	private String fSName;
	private String content;
	
	private String categoryMainCode;
	private String categoryMainName;
	private String categoryMiddleCode;
	private String categoryMiddleName;
	private String categorySubCode;
	private String categorySubName;
}
