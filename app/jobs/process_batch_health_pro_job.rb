class ProcessBatchHealthProJob < Struct.new(:batch_health_pro_id)
  def enqueue(job)
    job.delayed_reference_id   = batch_health_pro_id
    job.delayed_reference_type = BatchHealthPro.to_s
    job.save!
  end

  def error(job, exception)
    # Send email notification / alert / alarm
  end

  def failure(job)
    # Send email notification / alert / alarm / SMS / call ... whatever
  end

  def perform
    batch_health_pro = BatchHealthPro.find(batch_health_pro_id)
    batch_health_pro.import
  end
end