require 'capybara/rspec'
require 'selenium/webdriver'

module CapybaraExtension
  def drag_by(right_by, down_by)
    base.drag_by(right_by, down_by)
  end
end

module CapybaraSeleniumExtension
  def drag_by(right_by, down_by)
    driver.browser.action.drag_and_drop_by(native, right_by, down_by).perform
  end
end

::Capybara::Selenium::Node.include CapybaraSeleniumExtension
::Capybara::Node::Element.include CapybaraExtension

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless window-size=1024,768 disable-gpu] }
  )

  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 desired_capabilities: capabilities
end

Capybara.javascript_driver = :headless_chrome

Capybara.asset_host = 'http://localhost:3000'
