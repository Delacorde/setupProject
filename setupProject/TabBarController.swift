import UIKit

class TabBarController: UITabBarController{
    override func awakeFromNib() {
            super.awakeFromNib()
        print("таб бар контроллер создан")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
                
            let imagesListViewController = storyboard.instantiateViewController(
                withIdentifier: "ImagesListViewController"
            )
                
        let profileViewController = ProfileViewController()
        print(" профиль вью создан")
        
        profileViewController.tabBarItem = UITabBarItem(
            title: " ",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
               
           self.viewControllers = [imagesListViewController, profileViewController]
        print("вкладки установлены")
           }
}
