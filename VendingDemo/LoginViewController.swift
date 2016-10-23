/*
 * Copyright 2016 MasterCard International.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 * Redistributions of source code must retain the above copyright notice, this list of
 * conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials
 * provided with the distribution.
 * Neither the name of the MasterCard International Incorporated nor the names of its
 * contributors may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */
import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelLogin))
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func loginButtonPressed(_ sender: UIButton) {
    }
    
    // MARK: - Private methods
    func cancelLogin() {
        self.navigationController?.dismiss(animated: true, completion: nil)
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

// MARK: - FB SDK Login Button Delegate
extension LoginViewController: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        UIApplication.shared.keyWindow?.endEditing(true);
        if result == nil {
            NSLog(String(format:"something failed with error: %@", error.localizedDescription))
            return
        }
        if result.isCancelled {
            NSLog("Login Canceled");
            return
        }
        if result.token == nil {
            NSLog("Could not retrieve Facebook authentication.")
            return
        }
        
        APIClient.facebookLogin(withToken: result.token.tokenString, success: { (user: User?) in
            self.dismiss(animated: true, completion: {
                //
            })
        }) { (error: Error?, response: HTTPURLResponse?) in
            NSLog((error?.localizedDescription)!)
        }
//        [APIClient facebookLogin:result.token.tokenString success:^(User *user) {
//            //
//            [self dismissViewControllerAnimated:YES completion:nil];
//            //		[self performSegueWithIdentifier:@"addCardSegue" sender:self];
//            } failure:^(NSError *error, NSHTTPURLResponse *response) {
//            //
//            }];
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // do nothing
    }
}
