require "../common/common_response_codes"
require "../common/mail/mail_manager"
require "./api_helper"

# Отправляет почту
# Отвечает кодом ответа
post "/mail/send" do |env|
    begin
        subject = env.params.json["subject"]?.as?(String)
        message = env.params.json["message"]?.as?(String)
        recepient = env.params.json["recepient"]?.as?(String)

        if subject.nil? || message.nil? || recepient.nil?
            next getCodeResponse(BAD_REQUEST_ERROR)
        end

        MailManager.instance.sendMail(subject.not_nil!, message.not_nil!, recepient.not_nil!)

        next {
            code: OK_CODE
        }.to_json
    rescue
        next getCodeResponse(INTERNAL_ERROR)
    end
end