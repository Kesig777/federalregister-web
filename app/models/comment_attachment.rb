class CommentAttachment < ApplicationModel
  include EncryptionUtils
  require 'open-uri'

  ALLOWED_EXTENSIONS = ["bmp", "doc", "xls", "pdf", "gif", "htm", "html", "jpg", "jpeg", "png", "ppt", "rtf", "sgml", "tiff", "tif", "txt" , "wpd", "xml", "docx", "xlsx", "pptx"]
  MAX_FILE_SIZE = 10_000_000

  attr_accessor :secret

  before_create :generate_token
  before_validation :update_attachment_attributes

  validates_presence_of :attachment
  validates :file_size, :numericality => {:less_than => MAX_FILE_SIZE, :message => "must be less than 10MB"}
  validates :file_type, :format => {:with => /^#{ALLOWED_EXTENSIONS.join('|')}$/i, :message => "not allowed"}

  mount_uploader :attachment, AttachmentUploader

  def attachment_file_name
    attachment.try(:file).try(:filename)
  end

  def file_type
    attachment_file_name.try(:match,/\.(\w+)$/).try(:'[]',1)
  end

  def to_param
    token
  end

  def decrypt_to(dir)
    cipher = decryption_cipher

    buf = ""
    path = File.join(dir, File.basename(original_file_name))
    File.open(path, "wb") do |outf|
      open(attachment.url) do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end

    path
  end

  private

  def generate_token
    self.token = SecureRandom.hex(32)
  end

  def update_attachment_attributes
    if attachment.present? && (attachment_changed? || new_record?)
      self.content_type = attachment.file.content_type
      self.file_size = attachment.file.size
    end
  end
end
