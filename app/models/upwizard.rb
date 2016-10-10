require 'json'

class Upwizard < ApplicationRecord

  belongs_to :user
  attachment :file

  validates :user, presence: true

  # Return self
  def trace_push(now_step, params)
    #byebug
    now = Time.now
    h = {:step => now_step, :params => params, :back_step_skip => false, :time => now}
    tmp = trace_stack.push h
    store_trace_stack tmp
  end

  def trace_pop
    #byebug
    tmp = trace_stack
    ret = tmp.pop
    store_trace_stack tmp
    return ret
  end

  def trace_back_step_skip
    #byebug
    tmp = trace_stack
    tmp[-1]["back_step_skip"] = true
    store_trace_stack tmp
  end

  def trace_pop_back_step
    ret = trace_stack[-1]['step'] #There is always one

    if trace_stack.length == 2
      puts "************ trace_pop_back_step on top"
      tmp = trace_pop # remove the :go_back step
      tmp = trace_pop # remove the step where we clicked go_back
      ret = tmp['step'] # reenter the same
    else
      tmp = trace_pop # remove the :go_back step
      tmp = trace_pop # remove the step where we clicked go_back
      loop do
        tmp = trace_pop # remove the next and check if we can reenter it
        if tmp['back_step_skip'] == false
          ret = tmp['step']
          break
        end
      end
    end
    puts "************ trace_pop_back_step return: " + ret.inspect
    return ret
  end

  def trace_to_s
    ret = ""
    index = trace_stack.length - 1
    loop do
      break if index < 0
      tmp = trace_stack[index]
      ret = ret + "Step: " + tmp['step'].to_s + " "
      ret = ret + "Params: " + tmp['params'].to_s + " "
      ret = ret + "Time: " + tmp['time'].to_s + " "
      ret = ret + tmp['back_step_skip'].to_s + "\n"

      index = index - 1
    end
    return ret
  end

  def trace_stack
    #byebug
    if self.trace.blank?
      ret = []
    else
      ret = JSON.parse(self.trace)
    end
    return ret
  end

  def store_trace_stack (new_arr)
    self.trace = [].to_json if not self.trace.is_a?(Array)
    self.trace = new_arr.to_json
    #self.save
  end

end
