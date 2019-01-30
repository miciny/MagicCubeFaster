//
//  TabbarViewVontroller.swift
//  MagicCubeFaster
//
//  Created by maocaiyuan on 2019/1/21.
//  Copyright © 2019 maocaiyuan. All rights reserved.
//

//系统自带的tabbar
import UIKit

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTabbarItem()
        // Do any additional setup after loading the view.
    }
    
    func initTabbarItem(){
        
        //添加第一个试图，主页，主要展示卖宠物的和宠物周边商品
        let firstVC = MainViewController()
        let firstNav = UINavigationController(rootViewController: firstVC)
        firstNav.tabBarItem.title = "首页"
        firstNav.tabBarItem.image=UIImage(named: "Home_Unset")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal)      //设置工具栏选中前的图片
        firstNav.tabBarItem.selectedImage=UIImage(named: "Home_Set")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal) //设置工具栏选中后的图片
        
        self.viewControllers = [firstNav]            //添加至tab
        
        //底部工具栏背景颜色，
        self.tabBar.barTintColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 0.5)
        
        //设置底部工具栏文字颜色（默认状态和选中状态）
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(object:UIColor.black, forKey: NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : AnyObject], for:UIControlState());
        UITabBarItem.appearance().setTitleTextAttributes(NSDictionary(object: getMainColor(), forKey: NSAttributedStringKey.foregroundColor as NSCopying) as? [NSAttributedStringKey : AnyObject], for:UIControlState.selected)
        
        //导航栏颜色
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.black  //导航栏左右按钮文字颜色
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.black] //导航栏title文字颜色
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    //获得主色调
    func getMainColor() -> UIColor{
        let color = UIColor(red: 7/255, green: 191/255, blue: 5/255, alpha: 0.9)
        return color
    }
}

