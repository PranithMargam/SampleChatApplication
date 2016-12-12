//
//  FirstVC.swift
//  dynamicConstraintsDemo
//
//  Created by dmss on 16/11/16.
//  Copyright © 2016 pranith. All rights reserved.
//

import UIKit
import Firebase

protocol loginDelegate
{
    func fetchUsersAndSetUpData()
}
class FirstVC: UIViewController
{
    var delegate : loginDelegate?
    let containerVw: UIView = {
        let vw = UIView()
        vw.backgroundColor = UIColor.white
        vw.translatesAutoresizingMaskIntoConstraints = false
        
        vw.layer.cornerRadius = 5.0
        vw.layer.masksToBounds = true
        
        return vw
    }()
    
    lazy var  loginRegisterBtn: UIButton = {
       
        let btn = UIButton()
        btn.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(handleLoginOrRegister), for: .touchUpInside)
        return btn
    }()
    func handleLoginOrRegister()
    {
        if loginRegisterSegmentCntrl.selectedSegmentIndex == 0
        {
            handleLogin()
        }else
        {
            handleRegister()
        }
    }
    func handleLogin()
    {
        guard let email  = emailTxtFiled.text, let password = passwordTxtFiled.text
            else {
                print("form is error")
                return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil
            {
                print("failed to Login Error with: \(error?.localizedDescription)")
                return
            }
            //user succesfully loged in
            
            self.delegate?.fetchUsersAndSetUpData()
            self.perform(#selector(self.dismissViewController), with: nil, afterDelay: 0.5)
            
        })
        
    }
    func handleRegister()
    {
        guard let email  = emailTxtFiled.text, let password = passwordTxtFiled.text, let name = nameTextFiled.text
            else {
                print("form is error")
                return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user : FIRUser?, error) in
            
            if error != nil
            {
                print("faile To Communicate with error:\(error)")
                return
            }
            
            guard let uid = user?.uid else {
                
                return
            }
        
            let ref = FIRDatabase.database().reference(fromURL: "https://chatexampleapp-8e404.firebaseio.com/")
            let userRef = ref.child("users").child(uid)
            let values = ["name": name,"email":email]
            userRef.updateChildValues(values, withCompletionBlock: { (refError, FIRdatabaseRef) in
                
                if refError != nil
                {
                    print("fail to update login data with error:\(refError)")
                    return
                }
                //user Registered loged in
                
                self.delegate?.fetchUsersAndSetUpData()
                self.perform(#selector(self.dismissViewController), with: nil, afterDelay: 0.5)
                
            })
        })
    }
    func dismissViewController()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    let nameTextFiled : UITextField = {
       
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let nameSeparator: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    let emailTxtFiled : UITextField = {
        
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordTxtFiled : UITextField = {
       
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    let passwordSeparator: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let profileImgVw: UIImageView = {
       
        let imgVw = UIImageView()
        imgVw.image = UIImage(named: "Ico-User")
        imgVw.translatesAutoresizingMaskIntoConstraints = false
        
        return imgVw
    }()
    
    lazy var loginRegisterSegmentCntrl: UISegmentedControl = {
       
        let sc = UISegmentedControl(items: ["Login","Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleSegmentContrl), for: .valueChanged)
        return sc
        
    }()
    func handleSegmentContrl()
    {
        let title = loginRegisterSegmentCntrl.titleForSegment(at: loginRegisterSegmentCntrl.selectedSegmentIndex)
        loginRegisterBtn.setTitle(title, for: .normal)
        
        containerVwHeightConstraint?.constant = loginRegisterSegmentCntrl.selectedSegmentIndex == 0 ? 100: 150
        
        nameTxtFiledHeightConstraint?.isActive = false
        nameTxtFiledHeightConstraint = nameTextFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: loginRegisterSegmentCntrl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTxtFiledHeightConstraint?.isActive = true
        let isHidden = loginRegisterSegmentCntrl.selectedSegmentIndex == 0 ? true : false
        nameTextFiled.isHidden = isHidden
        nameSeparator.isHidden = isHidden
        
        emailTxtFiledHeightConstraint?.isActive = false
        emailTxtFiledHeightConstraint = emailTxtFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: loginRegisterSegmentCntrl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTxtFiledHeightConstraint?.isActive = true
        
        
        passwordTxtFiledHeightConstraint?.isActive = false
        passwordTxtFiledHeightConstraint = passwordTxtFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: loginRegisterSegmentCntrl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTxtFiledHeightConstraint?.isActive = true
       
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        
       // self.preferredStatusBarStyle = .lightContent
        
        self.view.addSubview(containerVw)
        self.view.addSubview(loginRegisterBtn)
        self.view.addSubview(profileImgVw)
        self.view.addSubview(loginRegisterSegmentCntrl)
        
        setupContainerVw()
        setupLoginRegisterButton()
        setUpProfileImageView()
        setUpLoginRegisterSegmentControl()
    }
    var containerVwHeightConstraint : NSLayoutConstraint?
    var nameTxtFiledHeightConstraint: NSLayoutConstraint?
    var emailTxtFiledHeightConstraint: NSLayoutConstraint?
    var passwordTxtFiledHeightConstraint: NSLayoutConstraint?
    
    func setupContainerVw()
    {
        //Need x,y width height
        containerVw.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        containerVw.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        containerVw.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        containerVwHeightConstraint = containerVw.heightAnchor.constraint(equalToConstant: 150)
        containerVwHeightConstraint?.isActive = true
        
        containerVw.addSubview(nameTextFiled)
        containerVw.addSubview(nameSeparator)
        containerVw.addSubview(emailTxtFiled)
        containerVw.addSubview(passwordSeparator)
        containerVw.addSubview(passwordTxtFiled)
        
        //Need x,y width height
        nameTextFiled.leftAnchor.constraint(equalTo: containerVw.leftAnchor, constant: 12).isActive = true
        nameTextFiled.topAnchor.constraint(equalTo: containerVw.topAnchor).isActive = true
        nameTextFiled.widthAnchor.constraint(equalTo: containerVw.widthAnchor, constant: -12).isActive = true
        nameTxtFiledHeightConstraint = nameTextFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: 1/3)
        nameTxtFiledHeightConstraint?.isActive = true
        
        
        //Need x,y width height
        nameSeparator.leftAnchor.constraint(equalTo: containerVw.leftAnchor).isActive = true
        nameSeparator.topAnchor.constraint(equalTo: nameTextFiled.bottomAnchor, constant: 1).isActive = true
        nameSeparator.widthAnchor.constraint(equalTo: containerVw.widthAnchor).isActive = true
        nameSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
         //Need x,y width height
        emailTxtFiled.leftAnchor.constraint(equalTo: nameTextFiled.leftAnchor).isActive = true
        emailTxtFiled.topAnchor.constraint(equalTo: nameTextFiled.bottomAnchor).isActive = true
        emailTxtFiled.widthAnchor.constraint(equalTo: nameTextFiled.widthAnchor).isActive = true
        emailTxtFiledHeightConstraint = emailTxtFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: 1/3)
        emailTxtFiledHeightConstraint?.isActive = true
        
        //Need x,y width height
        passwordSeparator.leftAnchor.constraint(equalTo: nameSeparator.leftAnchor).isActive = true
        passwordSeparator.topAnchor.constraint(equalTo: emailTxtFiled.bottomAnchor, constant: 1).isActive = true
        passwordSeparator.widthAnchor.constraint(equalTo: nameSeparator.widthAnchor).isActive = true
        passwordSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        
        //Need x,y width height
        passwordTxtFiled.leftAnchor.constraint(equalTo: nameTextFiled.leftAnchor).isActive = true
        passwordTxtFiled.topAnchor.constraint(equalTo: emailTxtFiled.bottomAnchor).isActive = true
        passwordTxtFiled.widthAnchor.constraint(equalTo: nameTextFiled.widthAnchor).isActive = true
        passwordTxtFiledHeightConstraint = passwordTxtFiled.heightAnchor.constraint(equalTo: containerVw.heightAnchor, multiplier: 1/3)
        passwordTxtFiledHeightConstraint?.isActive = true
    }
  
    func  setupLoginRegisterButton()
    {
        //Need x,y,width,height
        loginRegisterBtn.centerXAnchor.constraint(equalTo: containerVw.centerXAnchor).isActive = true
        loginRegisterBtn.topAnchor.constraint(equalTo: containerVw.bottomAnchor, constant: 12).isActive = true
        loginRegisterBtn.widthAnchor.constraint(equalTo: containerVw.widthAnchor).isActive = true
        loginRegisterBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    func  setUpProfileImageView()
    {
        profileImgVw.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImgVw.bottomAnchor.constraint(equalTo: containerVw.topAnchor, constant: -12).isActive = true
        profileImgVw.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImgVw.heightAnchor.constraint(equalTo: profileImgVw.widthAnchor).isActive = true
        
    }
    func setUpLoginRegisterSegmentControl()
    {
        loginRegisterSegmentCntrl.centerXAnchor.constraint(equalTo: containerVw.centerXAnchor).isActive = true
        loginRegisterSegmentCntrl.bottomAnchor.constraint(equalTo: containerVw.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentCntrl.widthAnchor.constraint(equalTo: containerVw.widthAnchor).isActive = true
        loginRegisterSegmentCntrl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
extension UIColor
{
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat)
    {
        self.init(red:r/255 ,green: g/255,blue: b/255, alpha: 1.0)
    }
}
