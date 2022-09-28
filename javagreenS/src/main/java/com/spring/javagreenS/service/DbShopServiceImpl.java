package com.spring.javagreenS.service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import com.spring.javagreenS.dao.DbShopDAO;
import com.spring.javagreenS.vo.DbBaesongVO;
import com.spring.javagreenS.vo.DbCartListVO;
import com.spring.javagreenS.vo.DbOptionVO;
import com.spring.javagreenS.vo.DbOrderVO;
import com.spring.javagreenS.vo.DbProductVO;

@Service
public class DbShopServiceImpl implements DbShopService {

	@Autowired
	DbShopDAO dbShopDAO;

	@Override
	public List<DbProductVO> getCategoryMain() {
		return dbShopDAO.getCategoryMain();
	}

	@Override
	public List<DbProductVO> getCategoryMiddle() {
		return dbShopDAO.getCategoryMiddle();
	}

	@Override
	public List<DbProductVO> getCategorySub() {
		return dbShopDAO.getCategorySub();
	}
	
	@Override
	public List<DbProductVO> getCategoryMiddleName(String categoryMainCode) {
		return dbShopDAO.getCategoryMiddleName(categoryMainCode);
	}

	@Override
	public List<DbProductVO> getCategorySubName(String categoryMainCode, String categoryMiddleCode) {
		return dbShopDAO.getCategorySubName(categoryMainCode, categoryMiddleCode);
	}
	
	@Override
	public DbProductVO getCategoryMainOne(String categoryMainCode, String categoryMainName) {
		return dbShopDAO.getCategoryMainOne(categoryMainCode, categoryMainName);
	}
	
	@Override
	public void categoryMainInput(DbProductVO vo) {
		dbShopDAO.setCategoryMainInput(vo);
	}

	@Override
	public List<DbProductVO> getCategoryMiddleOne(DbProductVO vo) {
		return dbShopDAO.getCategoryMiddleOne(vo);
	}

	@Override
	public void setCategoryMiddleInput(DbProductVO vo) {
		dbShopDAO.setCategoryMiddleInput(vo);
	}

	@Override
	public List<DbProductVO> getCategorySubOne(DbProductVO vo) {
		return dbShopDAO.getCategorySubOne(vo);
	}

	@Override
	public void setCategorySubInput(DbProductVO vo) {
		dbShopDAO.setCategorySubInput(vo);
	}

	@Override
	public void delCategoryMain(String categoryMainCode) {
		dbShopDAO.delCategoryMain(categoryMainCode);
	}

	@Override
	public void delCategoryMiddle(String categoryMiddleCode) {
		dbShopDAO.delCategoryMiddle(categoryMiddleCode);
	}

	@Override
	public List<DbProductVO> getDbProductOne(String categorySubCode) {
		return dbShopDAO.getDbProductOne(categorySubCode);
	}

	@Override
	public void delCategorySub(String categorySubCode) {
		dbShopDAO.delCategorySub(categorySubCode);
	}

	@SuppressWarnings("deprecation")
	@Override
	public void imgCheckProductInput(MultipartFile file, DbProductVO vo) {
		// 먼저 기본(메인)그림파일은 'dbShop/product'폴더에 업로드 시켜준다.
		try {
			String originalFilename = file.getOriginalFilename();
			if(originalFilename != null && originalFilename != "") {
				// 상품 메인사진을 업로드처리하기위해 중복파일명처리와 업로드처리
				Date date = new Date();
				SimpleDateFormat sdf = new SimpleDateFormat("yyMMddHHmmss");
			  String saveFileName = sdf.format(date) + "_" + originalFilename;
				writeFile(file, saveFileName);	  // 메일 이미지를 서버에 업로드 시켜주는 메소드 호출
				vo.setFName(originalFilename);		// 업로드시 파일명을 fName에 저장
				vo.setFSName(saveFileName);				// 서버에 저장된 파일명을 vo에 set시켜준다.
			}
			else {
				return;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		//             0         1         2         3         4         5
		//             012345678901234567890123456789012345678901234567890
		// <img alt="" src="/javagreenS/data/dbShop/211229124318_4.jpg"
		// <img alt="" src="/javagreenS/data/dbShop/product/211229124318_4.jpg"
		
		// ckeditor을 이용해서 담은 상품의 상세설명내역에 그림이 포함되어 있으면 그림을 dbShop/product폴더로 복사작업처리 시켜준다.
		String content = vo.getContent();
		if(content.indexOf("src=\"/") == -1) return;		// content박스의 내용중 그림이 없으면 돌아간다.
		
		HttpServletRequest request = ((ServletRequestAttributes)RequestContextHolder.currentRequestAttributes()).getRequest();
		String uploadPath = request.getRealPath("/resources/data/dbShop/");
		
		int position = 29;
		String nextImg = content.substring(content.indexOf("src=\"/") + position);
		boolean sw = true;
		
		while(sw) {
			String imgFile = nextImg.substring(0,nextImg.indexOf("\""));
			String copyFilePath = "";
			String oriFilePath = uploadPath + imgFile;	// 원본 그림이 들어있는 '경로명+파일명'
			
			copyFilePath = uploadPath + "product/" + imgFile;	// 복사가 될 '경로명+파일명'
			
			fileCopyCheck(oriFilePath, copyFilePath);	// 원본그림이 복사될 위치로 복사작업처리하는 메소드
			
			if(nextImg.indexOf("src=\"/") == -1) sw = false;
			else nextImg = nextImg.substring(nextImg.indexOf("src=\"/") + position);
		}
		// 이미지 복사작업이 종료되면 실제로 저장된 'dbShop/product'폴더명을 vo에 set시켜줘야 한다.
		vo.setContent(vo.getContent().replace("/data/dbShop/", "/data/dbShop/product/"));

		// 파일 복사작업이 모두 끝나면 vo에 담긴내용을 상품의 내역을 DB에 저장한다.
		// 먼저 productCode를 만들어주기 위해 지금까지 작업된 dbProduct테이블의 idx필드중 최대값을 읽어온다. 없으면 0으로 처리한다.
		int maxIdx = 0;
		DbProductVO maxVo = dbShopDAO.getProductMaxIdx();
		if(maxVo != null) {
			maxIdx = maxVo.getIdx() + 1;
			vo.setIdx(maxIdx);
		}
		vo.setProductCode(vo.getCategoryMainCode()+vo.getCategoryMiddleCode()+vo.getCategorySubCode()+maxIdx);
		dbShopDAO.setDbProductInput(vo);
	}
	
  // 실제 파일(dbShop폴더)을 'dbShop/product'폴더로 복사처리하는곳
	private void fileCopyCheck(String oriFilePath, String copyFilePath) {
		File oriFile = new File(oriFilePath);
		File copyFile = new File(copyFilePath);
		
		try {
			FileInputStream  fis = new FileInputStream(oriFile);
			FileOutputStream fos = new FileOutputStream(copyFile);
			
			byte[] buffer = new byte[2048];
			int count = 0;
			while((count = fis.read(buffer)) != -1) {
				fos.write(buffer, 0, count);
			}
			fos.flush();
			fos.close();
			fis.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	// 메인 상품 이미지 서버에 저장하기
	private void writeFile(MultipartFile fName, String saveFileName) throws IOException {
		byte[] data = fName.getBytes();
		
		HttpServletRequest request = ((ServletRequestAttributes)RequestContextHolder.currentRequestAttributes()).getRequest();
		String uploadPath = request.getSession().getServletContext().getRealPath("/resources/data/dbShop/product/");
		
		FileOutputStream fos = new FileOutputStream(uploadPath + saveFileName);
		fos.write(data);
		fos.close();
	}

	@Override
	public String[] getProductName() {
		return dbShopDAO.getProductName();
	}

	@Override
	public void setDbOptionInput(DbOptionVO vo) {
		dbShopDAO.setDbOptionInput(vo);
	}

	@Override
	public List<DbProductVO> getProductInfor(String productName) {
		return dbShopDAO.getProductInfor(productName);
	}

	@Override
	public List<DbProductVO> getDbShopList(String part) {
		return dbShopDAO.getDbShopList(part);
	}

	@Override
	public List<DbProductVO> getSubTitle() {
		return dbShopDAO.getSubTitle();
	}

	@Override
	public int getOptionSame(int productIdx, String optionName) {
		return dbShopDAO.getOptionSame(productIdx, optionName);
	}

	@Override
	public List<DbOptionVO> getOptionList(int productIdx) {
		return dbShopDAO.getOptionList(productIdx);
	}

	@Override
	public void setOptionDelete(int idx) {
		dbShopDAO.setOptionDelete(idx);
	}

	@Override
	public DbProductVO getDbShopProduct(int idx) {
		return dbShopDAO.getDbShopProduct(idx);
	}

	@Override
	public List<DbOptionVO> getDbShopOption(int productIdx) {
		return dbShopDAO.getDbShopOption(productIdx);
	}

	@Override
	public DbCartListVO getDbCartListProductOptionSearch(String productName, String optionName, String mid) {
		return dbShopDAO.getDbCartListProductOptionSearch(productName, optionName, mid);
	}

	@Override
	public void dbShopCartUpdate(DbCartListVO vo) {
		dbShopDAO.dbShopCartUpdate(vo);
	}

	@Override
	public void dbShopCartInput(DbCartListVO vo) {
		dbShopDAO.dbShopCartInput(vo);
	}

	@Override
	public List<DbCartListVO> getDbCartList(String mid) {
		return dbShopDAO.getDbCartList(mid);
	}

	@Override
	public void dbCartDelete(int idx) {
		dbShopDAO.dbCartDelete(idx);
	}

	@Override
	public void dbCartDeleteAll(int cartIdx) {
		dbShopDAO.dbCartDeleteAll(cartIdx);
	}

	@Override
	public DbCartListVO getCartIdx(int idx) {
		return dbShopDAO.getCartIdx(idx);
	}

	@Override
	public DbOrderVO getOrderMaxIdx() {
		return dbShopDAO.getOrderMaxIdx();
	}

	@Override
	public void setDbOrder(DbOrderVO vo) {
		dbShopDAO.setDbOrder(vo);
	}

	@Override
	public int getOrderOIdx(int orderIdx) {
		return dbShopDAO.getOrderOIdx(orderIdx);
	}

	@Override
	public void setDbBaesong(DbBaesongVO baesongVo) {
		dbShopDAO.setDbBaesong(baesongVo);
	}

	@Override
	public void setMemberPointPlus(int point, String mid) {
		dbShopDAO.setMemberPointPlus(point, mid);
	}

	@Override
	public List<DbBaesongVO> getBaesong(String mid) {
		return dbShopDAO.getBaesong(mid);
	}

	@Override
	public List<DbBaesongVO> getOrderBaesong(String orderIdx) {
		return dbShopDAO.getOrderBaesong(orderIdx);
	}

	@Override
	public List<DbProductVO> getMyOrderList(int startIndexNo, int pageSize, String mid) {
		return dbShopDAO.getMyOrderList(startIndexNo, pageSize, mid);
	}

	@Override
	public List<DbBaesongVO> getMyOrderStatus(int startIndexNo, int pageSize, String mid, String startJumun, String endJumun,	String conditionOrderStatus) {
		return dbShopDAO.getMyOrderStatus(startIndexNo, pageSize, mid, startJumun, endJumun,	conditionOrderStatus);
	}

	@Override
	public List<DbBaesongVO> getOrderStatus(String mid, String orderStatus, int startIndexNo, int pageSize) {
		return dbShopDAO.getOrderStatus(mid, orderStatus, startIndexNo, pageSize);
	}

	@Override
	public List<DbBaesongVO> getOrderCondition(String mid, int conditionDate, int startIndexNo, int pageSize) {
		return dbShopDAO.getOrderCondition(mid, conditionDate, startIndexNo, pageSize);
	}

	@Override
	public List<DbBaesongVO> getAdminOrderStatus(String startJumun, String endJumun, String orderStatus) {
		//System.out.println("startJumun: " + startJumun + ", endJumun: " + endJumun + ", orderStatus : " + orderStatus);
		return dbShopDAO.getAdminOrderStatus(startJumun, endJumun, orderStatus);
	}

	@Override
	public void setOrderStatusUpdate(String orderIdx, String orderStatus) {
		dbShopDAO.setOrderStatusUpdate(orderIdx, orderStatus);
	}
}
